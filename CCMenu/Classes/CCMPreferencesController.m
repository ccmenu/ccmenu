
#import "CCMPreferencesController.h"
#import "CCMUserDefaultsManager.h"
#import "CCMConnection.h"
#import "NSArray+CCMAdditions.h"
#import "NSString+CCMAdditions.h"
#import <EDCommon/EDCommon.h>

#define WINDOW_TITLE_HEIGHT 78

NSString *CCMPreferencesChangedNotification = @"CCMPreferencesChangedNotification";


@implementation CCMPreferencesController

- (void)showWindow:(id)sender
{
	if(preferencesWindow == nil)
	{
		[NSBundle loadNibNamed:@"Preferences" owner:self];
		[preferencesWindow center];
		[preferencesWindow setToolbar:[self createToolbarWithName:@"Preferences"]];
		[[preferencesWindow toolbar] setSelectedItemIdentifier:@"Projects"];
		[self switchPreferencesPane:self];
		[versionField setStringValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
	}
    [soundNamesViewController setContent:[self availableSounds]];
	[NSApp activateIgnoringOtherApps:YES];
	[preferencesWindow makeKeyAndOrderFront:self];	
}

- (void)switchPreferencesPane:(id)sender
{
	NSString *selectedIdentifier = [[preferencesWindow toolbar] selectedItemIdentifier];
	int index = [[self toolbarDefaultItemIdentifiers:nil] indexOfObject:selectedIdentifier];
	NSArray *allViews = [NSArray arrayWithObjects:projectsView, notificationPrefsView, advancedPrefsView, nil];
	NSView *prefView = [allViews objectAtIndex:index];
	NSDictionary *itemDef = [[toolbarDefinition objectForKey:@"itemInfoByIdentifier"] objectForKey:selectedIdentifier];
	[preferencesWindow setTitle:[itemDef objectForKey:@"label"]]; 
    
	NSRect windowFrame = [preferencesWindow frame];
	windowFrame.size.height = [prefView frame].size.height + WINDOW_TITLE_HEIGHT;
	windowFrame.size.width = [prefView frame].size.width;
	windowFrame.origin.y = NSMaxY([preferencesWindow frame]) - ([prefView frame].size.height + WINDOW_TITLE_HEIGHT);
	
	if([[paneHolderView subviews] count] > 0)
		[[[paneHolderView subviews] firstObject] removeFromSuperview];
	[preferencesWindow setFrame:windowFrame display:YES animate:(sender != self)];
	
	[paneHolderView setFrame:[prefView frame]];
	[paneHolderView addSubview:prefView];
}

- (void)addProjects:(id)sender
{
	NSArray *urls = [defaultsManager serverURLHistory];
	if([urls count] > 0)
	{
		[serverUrlComboBox removeAllItems];
		urls = [urls sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
		[serverUrlComboBox addItemsWithObjectValues:urls];
	}
	[sheetTabView selectFirstTabViewItem:self];
	[NSApp beginSheet:addProjectsSheet modalForWindow:preferencesWindow modalDelegate:self 
		didEndSelector:@selector(addProjectsSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)historyURLSelected:(id)sender
{
	NSString *serverUrl = [serverUrlComboBox stringValue];
	[serverTypeMatrix selectCellWithTag:[serverUrl serverType]];
}

- (void)serverTypeChanged:(id)sender
{
	NSString *serverUrl = [serverUrlComboBox stringValue];
	serverUrl = [serverUrl stringByRemovingServerReportFileName];
	if([serverTypeMatrix selectedTag] != CCMUnknownServer)
		serverUrl = [serverUrl completeURLForServerType:[serverTypeMatrix selectedTag]];
	[serverUrlComboBox setStringValue:serverUrl];
}


- (void)chooseProjects:(id)sender
{
	@try 
	{
		[testServerProgressIndicator startAnimation:self];
		NSString *serverUrl = [serverUrlComboBox stringValue];
		if([serverTypeMatrix selectedTag] == CCMUnknownServer)
		{
			if((serverUrl = [self determineServerURL]) == nil)
			{
				[testServerProgressIndicator stopAnimation:self];
				NSAlert *alert = [[[NSAlert alloc] init] autorelease];
				[alert setMessageText:NSLocalizedString(@"Cannot determine server type", "Alert message when server type cannot be determined.")];
				[alert setInformativeText:NSLocalizedString(@"Please contact the server administrator and enter the full URL into the location field.", "Informative text when server type cannot be determined.")];
				[alert runModal];
				return;
			}
		}
		CCMConnection *connection = [[[CCMConnection alloc] initWithURLString:serverUrl] autorelease];
		NSArray *projectInfos = [connection retrieveServerStatus];
		[testServerProgressIndicator stopAnimation:self];
		[chooseProjectsViewController setContent:[self convertProjectInfos:projectInfos withServerUrl:serverUrl]];
		[sheetTabView selectNextTabViewItem:self];
	}
	@catch(NSException *exception) 
	{
		[testServerProgressIndicator stopAnimation:self];
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert setMessageText:NSLocalizedString(@"Could not retrieve project information", "Alert message when connection fails in preferences.")];
		[alert setInformativeText:[exception reason]];
		[alert runModal];
	}
}

- (NSString *)determineServerURL
{
	NSString *originalUrl = [serverUrlComboBox stringValue];
    for(NSString *url in [originalUrl completeURLForAllServerTypes])
	{
		[serverUrlComboBox setStringValue:url];
		[serverUrlComboBox display];
		CCMConnection *connection = [[[CCMConnection alloc] initWithURLString:url] autorelease];
		if([connection testConnection])
			return url;
	}
	[serverUrlComboBox setStringValue:originalUrl];
	[serverUrlComboBox display];
	return nil;
}

- (NSArray *)convertProjectInfos:(NSArray *)projectInfos withServerUrl:(NSString *)serverUrl 
{
	NSMutableArray *result = [NSMutableArray array];
	for(NSDictionary *projectInfo in projectInfos)
	{
		NSMutableDictionary *listEntry = [NSMutableDictionary dictionary];
		NSString *projectName = [projectInfo objectForKey:@"name"];
		[listEntry setObject:projectName forKey:@"name"];
		[listEntry setObject:serverUrl forKey:@"server"];
		if([defaultsManager projectListContainsProject:projectName onServerWithURL:serverUrl])
			[listEntry setObject:[NSColor disabledControlTextColor] forKey:@"textColor"];
		[result addObject:listEntry];
	}
	return result;
}


- (void)closeAddProjectsSheet:(id)sender
{
	[NSApp endSheet:addProjectsSheet returnCode:[sender tag]];
}

- (void)addProjectsSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[addProjectsSheet orderOut:self];
	if(returnCode == 0)
		return;

    for(NSDictionary *entry in [chooseProjectsViewController selectedObjects])
	{
		NSString *serverUrl = [entry objectForKey:@"server"];
		[defaultsManager addProject:[entry objectForKey:@"name"] onServerWithURL:serverUrl];
		[defaultsManager addServerURLToHistory:serverUrl];
	}
	[self preferencesChanged:self];
}


- (void)removeProjects:(id)sender
{
	[allProjectsViewController remove:sender];
	[self preferencesChanged:sender];
}


- (NSArray *)availableSounds
{
    NSMutableArray *sounds = [NSMutableArray arrayWithObject:@"-"];
    for(NSString *libPath in NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSAllDomainsMask, YES)) 
    {
        NSString *soundLibPath = [libPath stringByAppendingPathComponent:@"Sounds"];
        for (NSString *filename in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:soundLibPath error:nil]) 
        {
            if([filename hasPrefix:@"."] == NO)
                [sounds addObject:[filename stringByDeletingPathExtension]];
        }
    }
    return sounds;
}

- (void)soundSelected:(id)sender
{
    [[NSSound soundNamed:[sender title]] play];
}


- (void)preferencesChanged:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:CCMPreferencesChangedNotification object:sender];
}

- (IBAction)updateIntervalChanged:(id)sender
{
	[updater scheduleCheckWithInterval:[sender selectedTag]];
}

- (IBAction)checkForUpdateNow:(id)sender
{
    [updater checkForUpdates:sender];
}

@end
