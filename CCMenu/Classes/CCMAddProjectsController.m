
#import "NSString+CCMAdditions.h"
#import "NSAlert+CCMAdditions.h"
#import "CCMHistoryDataSource.h"
#import "CCMAddProjectsController.h"
#import "CCMSyncConnection.h"
#import "CCMKeychainHelper.h"
#import "CCMPreferencesController.h"
#import "strings.h"


@implementation CCMAddProjectsController

- (void)beginSheetForWindow:(NSWindow *)aWindow
{
    [(CCMHistoryDataSource *)[serverUrlComboBox dataSource] reloadData:defaultsManager];
    [serverUrlComboBox reloadData];
    [serverUrlComboBox setStringValue:@""];
 	[serverTypeMatrix selectCellWithTag:CCMDetectServer];
    [credentialBox retain]; // memory leak
    [credentialBox removeFromSuperview];
	[sheetTabView selectFirstTabViewItem:self];
	[NSApp beginSheet:addProjectsSheet modalForWindow:aWindow modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
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
    [self rememberCredentialBoxVisibility];
    NSString *url = [serverUrlComboBox stringValue];
    NSInteger statusCode = [self checkURL:url];
    if(statusCode != 200)
    {
        [testServerProgressIndicator stopAnimation:self];
        if([self didCredentialBoxBecomeVisible])
            return nil;
        [[NSAlert alertWithText:ALERT_CONN_FAILURE_TITLE informativeText:[NSString stringWithFormat:(statusCode == 401) ? ALERT_CONN_FAILURE_STATUS401_INFO : ALERT_CONN_FAILURE_STATUS_INFO, (int)statusCode]] runModal];
        return nil;
    }
    return url;
}

- (NSString *)getCompletedAndValidatedURL
{
    BOOL saw401 = NO;
    NSString *url = nil;
    NSString *baseURL = [serverUrlComboBox stringValue];
    [self rememberCredentialBoxVisibility];
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
        if([self didCredentialBoxBecomeVisible])
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

- (void)rememberCredentialBoxVisibility
{
    credentialBoxWasVisible = ([credentialBox superview] != nil);
}

- (BOOL)didCredentialBoxBecomeVisible
{
    return ((credentialBoxWasVisible == NO) && ([credentialBox superview] != nil));
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


- (void)closeSheet:(id)sender
{
	[NSApp endSheet:addProjectsSheet returnCode:[sender tag]];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
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
    [[NSNotificationCenter defaultCenter] postNotificationName:CCMPreferencesChangedNotification object:self];
}

@end
