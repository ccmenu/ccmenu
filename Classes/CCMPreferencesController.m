
#import "CCMPreferencesController.h"
#import "CCMConnection.h"
#import "NSArray+CCMAdditions.h"
#import <EDCommon/EDCommon.h>

#define WINDOW_TITLE_HEIGHT 78

NSString *CCMDefaultsProjectListKey = @"Projects";
NSString *CCMDefaultsProjectEntryNameKey = @"projectName";
NSString *CCMDefaultsProjectEntryServerUrlKey = @"serverUrl";
NSString *CCMDefaultsPollIntervalKey = @"PollInterval";

NSString *CCMPreferencesChangedNotification = @"CCMPreferencesChangedNotification";


@implementation CCMPreferencesController

- (void)awakeFromNib
{
	userDefaults = [NSUserDefaults standardUserDefaults];
}

- (NSArray *)defaultsProjectList
{
	NSData *defaultsData = [userDefaults dataForKey:CCMDefaultsProjectListKey];
	if(defaultsData == nil)
		return [NSArray array];
	return [NSUnarchiver unarchiveObjectWithData:defaultsData];
}

- (NSURL *)getServerURL
{
	NSString *serverUrl = [serverUrlComboBox stringValue];
	if(![serverUrl hasPrefix:@"http://"])
	{
		serverUrl = [@"http://" stringByAppendingString:serverUrl];
		[serverUrlComboBox setStringValue:serverUrl];
	}
	NSArray *allFilenames = [NSArray arrayWithObjects:@"cctray.xml", @"xml.jsp", @"XmlStatusReport.aspx", @"XmlStatusReport.aspx", @"", nil];
	NSString *filename = [allFilenames objectAtIndex:[serverTypeMatrix selectedTag]];
	if(([serverUrl length] > 0) && (![serverUrl hasSuffix:filename]))
	{
		if(![serverUrl hasSuffix:@"/"])
			serverUrl = [serverUrl stringByAppendingString:@"/"];
		serverUrl = [serverUrl stringByAppendingString:filename];
	}
	return [NSURL URLWithString:serverUrl];
}

- (void)showWindow:(id)sender
{
	if(preferencesWindow == nil)
	{
		[NSBundle loadNibNamed:@"Preferences" owner:self];
		[preferencesWindow center];
		[preferencesWindow setToolbar:[self createToolbarWithName:@"Preferences"]];
		[[preferencesWindow toolbar] setSelectedItemIdentifier:@"Projects"];
		[self switchPreferencesPane:self];
		[versionField setStringValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
	}
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
	NSArray *projects = [self defaultsProjectList];
	if([projects count] > 0)
	{
		NSArray *urls = [[projects collect] objectForKey:CCMDefaultsProjectEntryServerUrlKey];
		urls = [[NSSet setWithArray:urls] allObjects];
		[serverUrlComboBox removeAllItems];
		[serverUrlComboBox addItemsWithObjectValues:urls];
	}
	[sheetTabView selectFirstTabViewItem:self];
	[NSApp beginSheet:addProjectsSheet modalForWindow:preferencesWindow modalDelegate:self 
		didEndSelector:@selector(addProjectsSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)chooseProjects:(id)sender
{
	@try 
	{
		[testServerProgressIndicator startAnimation:self];
		CCMConnection *connection = [[[CCMConnection alloc] initWithURL:[self getServerURL]] autorelease];
		NSArray *projectInfos = [connection getProjectInfos];
		[testServerProgressIndicator stopAnimation:self];
		[chooseProjectsViewController setContent:projectInfos];
		[sheetTabView selectNextTabViewItem:self];
	}
	@catch(NSException *exception) 
	{
		[testServerProgressIndicator stopAnimation:self];
		NSRunAlertPanel(@"Connection failure", @"Could not connect to server. %@", @"Cancel", nil, nil, [exception reason]);
	}
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

	NSMutableArray *defaultsProjectList = [[[self defaultsProjectList] mutableCopy] autorelease];
	
	NSEnumerator *projectInfoEnum = [[chooseProjectsViewController selectedObjects] objectEnumerator];
	NSDictionary *projectInfo;
	while((projectInfo = [projectInfoEnum nextObject]) != nil)
	{
		NSDictionary *defaultsProjectListEntry = [NSDictionary dictionaryWithObjectsAndKeys:
			[projectInfo objectForKey:@"name"], CCMDefaultsProjectEntryNameKey, 
			[[self getServerURL] absoluteString], CCMDefaultsProjectEntryServerUrlKey, nil];
		if(![defaultsProjectList containsObject:defaultsProjectListEntry])
		   [defaultsProjectList addObject:defaultsProjectListEntry];
	}
	NSData *data = [NSArchiver archivedDataWithRootObject:defaultsProjectList];
	[userDefaults setObject:data forKey:CCMDefaultsProjectListKey];
	[self preferencesChanged:self];
}

- (IBAction)removeProjects:(id)sender
{
	[allProjectsViewController remove:sender];
	[self preferencesChanged:sender];
}

- (void)preferencesChanged:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:CCMPreferencesChangedNotification object:sender];
}

@end
