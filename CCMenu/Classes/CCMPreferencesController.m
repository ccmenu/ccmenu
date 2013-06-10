
#import "CCMPreferencesController.h"
#import "CCMConnection.h"
#import "NSString+CCMAdditions.h"
#import "NSAlert+CCMAdditions.h"
#import "NSArray+EDExtensions.h"
#import "NSAppleScript+EDAdditions.h"
#import "CCMSyncConnection.h"
#import "CCMHistoryDataSource.h"
#import "CCMKeychainHelper.h"

#define WINDOW_TITLE_HEIGHT 78

#define ALERT_SERVER_DETECT_FAILURE_TITLE NSLocalizedString(@"Cannot determine server type", "Alert message when server type cannot be determined.")
#define ALERT_SERVER_DETECT_FAILURE_INFO NSLocalizedString(@"Please contact the server administrator to get the feed URL, and then enter the full URL into the field.", "Informative text when server type cannot be determined.")

#define ALERT_CONN_FAILURE_TITLE NSLocalizedString(@"Cannot retrieve project information", "Alert message when connection test fails in preferences.")
#define ALERT_CONN_FAILURE_STATUS_INFO NSLocalizedString(@"The server responded with HTTP status code %d.", "Informative text when server responded with anything but 200 OK. Placeholder is for status code.")
#define ALERT_CONN_FAILURE_STATUS401_INFO NSLocalizedString(@"The server responded with HTTP status code 401, which means \"not authorized\". Please make sure that the username and password are correct.", "Informative text when server responded with status code 401.")

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
        NSString *shortVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
		[versionField setStringValue:[NSString stringWithFormat:@"%@ (r%@)", shortVersion, version]];
	}
    [soundNamesViewController setContent:[self availableSounds]];
	[NSApp activateIgnoringOtherApps:YES];
	[preferencesWindow makeKeyAndOrderFront:self];	
}

- (void)switchPreferencesPane:(id)sender
{
	NSString *selectedIdentifier = [[preferencesWindow toolbar] selectedItemIdentifier];
	NSUInteger index = [[self toolbarDefaultItemIdentifiers:nil] indexOfObject:selectedIdentifier];
	NSArray *allViews = [NSArray arrayWithObjects:projectsView, notificationPrefsView, advancedPrefsView, aboutView, nil];
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
    [(CCMHistoryDataSource *)[serverUrlComboBox dataSource] reloadData:defaultsManager];
    [serverUrlComboBox reloadData];
    [serverUrlComboBox setStringValue:@""];
 	[serverTypeMatrix selectCellWithTag:CCMDetectServer];
    [credentialBox retain]; // memory leak
    [credentialBox removeFromSuperview];
	[sheetTabView selectFirstTabViewItem:self];
	[NSApp beginSheet:addProjectsSheet modalForWindow:preferencesWindow modalDelegate:self 
		didEndSelector:@selector(addProjectsSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)historyURLSelected:(id)sender
{
//	[serverTypeMatrix selectCellWithTag:CCMUseGivenURL];
    [serverUrlComboBox selectText:self];
    NSString *user = [[serverUrlComboBox stringValue] usernameFromURL];
    [userField setStringValue:(user != nil) ? user : @""];
    [passwordField setStringValue:@""];
}

- (void)serverDetectionChanged:(id)sender
{
    [serverUrlComboBox setStringValue:[[serverUrlComboBox stringValue] stringByAddingSchemeIfNecessary]];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    if([aNotification object] == userField)
    {
        NSString *serverUrl = [[serverUrlComboBox stringValue] stringByAddingSchemeIfNecessary];
        NSString *userFromUrl = [serverUrl usernameFromURL];
        if(userFromUrl != nil)
        {
            NSRange userRange = [serverUrl rangeOfString:userFromUrl];
            serverUrl = [serverUrl stringByReplacingCharactersInRange:userRange withString:[userField stringValue]];
        }
        else
        {
            NSRange userRange = NSMakeRange(NSMaxRange([serverUrl rangeOfString:@"//"]), 0);
            NSString *user = [[userField stringValue] stringByAppendingString:@"@"];
            serverUrl = [serverUrl stringByReplacingCharactersInRange:userRange withString:user];
        }
        [serverUrlComboBox setStringValue:serverUrl];
    }
}

- (void)chooseProjects:(id)sender
{
	@try 
	{
		[testServerProgressIndicator startAnimation:self];
        NSString *serverUrl = ([serverTypeMatrix selectedTag] == CCMUseGivenURL) ? [self getValidatedURL] : [self getCompletedAndValidatedURL];
        if(serverUrl == nil)
            return;
        CCMSyncConnection *connection = [[[CCMSyncConnection alloc] initWithURLString:serverUrl] autorelease];
        [connection setDelegate:self];
        NSArray *projectInfos = [connection retrieveServerStatus];
        [chooseProjectsViewController setContent:[self convertProjectInfos:projectInfos withServerUrl:serverUrl]];
        [sheetTabView selectLastTabViewItem:self];
    }
	@catch(NSException *exception)
	{
		[testServerProgressIndicator stopAnimation:self];
        [[NSAlert alertWithText:ALERT_CONN_FAILURE_TITLE informativeText:[exception reason]] runModal];
    }
    @finally
    {
        [testServerProgressIndicator stopAnimation:self];
    }
}

- (NSString *)getValidatedURL
{
    BOOL wasVisible = [self isCredentialBoxVisible];
    NSString *url = [serverUrlComboBox stringValue];
    NSInteger statusCode = [self checkURL:url];
    if(statusCode != 200)
    {
        [testServerProgressIndicator stopAnimation:self];
        if([self didCredentialBoxBecomeVisible:wasVisible])
            return nil;
        [[NSAlert alertWithText:ALERT_CONN_FAILURE_TITLE informativeText:[NSString stringWithFormat:(statusCode == 401) ? ALERT_CONN_FAILURE_STATUS401_INFO : ALERT_CONN_FAILURE_STATUS_INFO, (int)statusCode]] runModal];
        return nil;
    }
    return url;
}

- (NSString *)getCompletedAndValidatedURL
{
    BOOL wasVisible = [self isCredentialBoxVisible];
    BOOL saw401 = NO;
    NSString *url = nil;
    NSString *baseURL = [serverUrlComboBox stringValue];
    for(NSString *completedURL in [baseURL completeURLForAllServerTypes])
    {
        [serverUrlComboBox setStringValue:completedURL];
        [serverUrlComboBox display];
        NSInteger status = [self checkURL:completedURL];
        if(status == 200)
        {
            url = completedURL;
            break;
        }
        else if(status == 401)
        {
            saw401 = YES;
        }
    }
    if(url == nil)
    {
        [serverUrlComboBox setStringValue:baseURL];
        [serverUrlComboBox display];
        [testServerProgressIndicator stopAnimation:self];
        if([self didCredentialBoxBecomeVisible:wasVisible])
            return nil;
        [[NSAlert alertWithText:ALERT_SERVER_DETECT_FAILURE_TITLE informativeText:saw401 ? ALERT_CONN_FAILURE_STATUS401_INFO : ALERT_SERVER_DETECT_FAILURE_INFO] runModal];
        return nil;
    }
    return url;
}


- (NSInteger)checkURL:(NSString *)url
{
    CCMSyncConnection *connection = [[[CCMSyncConnection alloc] initWithURLString:url] autorelease];
    if([credentialBox superview] != nil)
    {
        NSURLCredential *credential = [NSURLCredential credentialWithUser:[userField stringValue] password:[passwordField stringValue] persistence:NSURLCredentialPersistencePermanent];
        [connection setCredential:credential];
    }

    NSInteger statusCode = [connection testConnection];

    if((statusCode == 401) && ([credentialBox superview] == nil))
    {
        NSString *user = [url usernameFromURL];
        [userField setStringValue:(user != nil) ? user : @""];
        NSString *password = [CCMKeychainHelper passwordForURLString:url error:NULL];
        [passwordField setStringValue:(password != nil) ? password : @""];
        [credentialBox setAlphaValue:0.0f];
        [[credentialBox animator] setAlphaValue:1.0f];
        [[[serverUrlComboBox superview] animator] addSubview:credentialBox];
    }
    return statusCode;
}

- (BOOL)isCredentialBoxVisible
{
    return ([credentialBox superview] != nil);
}

- (BOOL)didCredentialBoxBecomeVisible:(BOOL)previousState
{
    return ((previousState == NO) && ([self isCredentialBoxVisible] == YES));
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


- (void)editProject:(id)sender
{
    NSString *password = [CCMKeychainHelper passwordForURLString:@"http://dev@localhost:4567" error:NULL];
    [editPasswordField setStringValue:(password != nil) ? password : @""];
    [NSApp beginSheet:editProjectSheet modalForWindow:preferencesWindow modalDelegate:self
       didEndSelector:@selector(editProjectSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)closeEditProjectSheet:(id)sender
{
	[NSApp endSheet:editProjectSheet returnCode:[sender tag]];
}

- (void)editProjectSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[editProjectSheet orderOut:self];
	if(returnCode == 0)
		return;

   	[self preferencesChanged:self];
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

- (IBAction)openNotificationPreferences:(id)sender
{
    [[NSAppleScript scriptWithName:@"handlers"] callHandler:@"open_notifications"];
}

- (void)preferencesChanged:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:CCMPreferencesChangedNotification object:sender];
}

- (IBAction)updateIntervalChanged:(id)sender
{
	[updater setUpdateCheckInterval:(NSTimeInterval)[sender selectedTag]];
}

- (IBAction)checkForUpdateNow:(id)sender
{
    [updater checkForUpdates:sender];
}

@end
