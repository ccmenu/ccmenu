
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
    [authCheckBox setState:NSOffState];
    [userField setStringValue:@""];
    [passwordField setStringValue:@""];
    [self showTestInProgress:NO];
	[sheetTabView selectFirstTabViewItem:self];
	[NSApp beginSheet:addProjectsSheet modalForWindow:aWindow modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)historyURLSelected:(id)sender
{
    [serverUrlComboBox selectText:self];
    NSString *user = [[serverUrlComboBox stringValue] user];
    [authCheckBox setState:(user != nil) ? NSOnState : NSOffState];
    [self useAuthenticationChanged:self];
}

- (void)serverDetectionChanged:(id)sender
{
    [serverUrlComboBox setStringValue:[[serverUrlComboBox stringValue] stringByAddingSchemeIfNecessary]];
}

- (IBAction)useAuthenticationChanged:(id)sender
{
    NSString *url = [[serverUrlComboBox stringValue] stringByAddingSchemeIfNecessary];

    if([authCheckBox state] == NSOnState)
    {
        NSString *user = [url user];
        if(user == nil)
        {
            user = [CCMKeychainHelper accountForURLString:url error:NULL];
            if(user == nil)
                return;
            url = [url stringByReplacingCredentials:user];
            [serverUrlComboBox setStringValue:url];
        }
        [userField setStringValue:user];
        NSString *password = [CCMKeychainHelper passwordForURLString:url error:NULL];
        [passwordField setStringValue:(password != nil) ? password : @""];
    }
    else
    {
        [serverUrlComboBox setStringValue:[url stringByReplacingCredentials:@""]];
        [userField setStringValue:@""];
        [passwordField setStringValue:@""];
    }
}


- (void)controlTextDidChange:(NSNotification *)aNotification
{
    if([aNotification object] == userField)
    {
        NSString *url = [[serverUrlComboBox stringValue] stringByAddingSchemeIfNecessary];
        [serverUrlComboBox setStringValue:[url stringByReplacingCredentials:[userField stringValue]]];
    }
}

- (void)chooseProjects:(id)sender
{
	@try
	{
        [self showTestInProgress:YES];
        BOOL useAsGiven = [serverTypeMatrix selectedTag] == CCMUseGivenURL;
        NSString *serverUrl = useAsGiven ? [self getValidatedURL] : [self getCompletedAndValidatedURL];
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
        [self showTestInProgress:NO];
        [[NSAlert alertWithText:ALERT_CONN_FAILURE_TITLE informativeText:[exception reason]] runModal];
    }
    @finally
    {
        [self showTestInProgress:NO];
    }
}

- (NSString *)getValidatedURL
{
    NSString *url = [serverUrlComboBox stringValue];
    NSInteger statusCode = [self checkURL:url];
    if(statusCode != 200)
    {
        [self showTestInProgress:NO];
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
        [self showTestInProgress:NO];
        [[NSAlert alertWithText:ALERT_SERVER_DETECT_FAILURE_TITLE informativeText:saw401 ? ALERT_CONN_FAILURE_STATUS401_INFO : ALERT_SERVER_DETECT_FAILURE_INFO] runModal];
        return nil;
    }
    return url;
}


- (NSInteger)checkURL:(NSString *)url
{
    CCMSyncConnection *connection = [[[CCMSyncConnection alloc] initWithURLString:url] autorelease];
    if([authCheckBox state] == NSOnState)
    {
        NSURLCredential *credential = [NSURLCredential credentialWithUser:[userField stringValue] password:[passwordField stringValue] persistence:NSURLCredentialPersistenceNone];
        [connection setCredential:credential];
    }
    NSInteger statusCode = [connection testConnection];
    if((statusCode == 200) && ([connection credential] != nil))
    {
        [CCMKeychainHelper setPassword:[[connection credential] password] forURLString:url error:NULL];
    }
    return statusCode;
}

- (void)showTestInProgress:(BOOL)flag
{
    if(flag)
    {
		[testServerProgressIndicator startAnimation:self];
        [statusField setStringValue:STATUS_TESTING];
    }
    else
    {
        [testServerProgressIndicator stopAnimation:self];
        [statusField setStringValue:@""];
    }
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
