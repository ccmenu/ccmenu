#import "CCMEditProjectController.h"
#import "CCMKeychainHelper.h"
#import "CCMPreferencesController.h"
#import "CCMSyncConnection.h"
#import "NSString+CCMAdditions.h"
#import "strings.h"
#import "NSAlert+CCMAdditions.h"


@implementation CCMEditProjectController

- (void)beginSheetForWindow:(NSWindow *)aWindow
{
    NSString *password = [CCMKeychainHelper passwordForURLString:[[self selectedProject] objectForKey:@"serverUrl"] error:NULL];
    [passwordField setStringValue:(password != nil) ? password : @""];
    [NSApp beginSheet:editProjectSheet modalForWindow:aWindow modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)closeSheet:(id)sender
{
    if([sender tag] != 0)
    {
        NSString *url = [self getValidatedURL];
        if(url == nil)
            return;
    }

    [NSApp endSheet:editProjectSheet returnCode:[sender tag]];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [editProjectSheet orderOut:self];
    if(returnCode == 0)
        return;

    NSString *projectName = [[self selectedProject] objectForKey:@"projectName"];
    NSString *serverUrl = [[self selectedProject] objectForKey:@"serverUrl"];
    [allProjectsViewController remove:self];
    [defaultsManager addProject:projectName onServerWithURL:serverUrl];

    [[NSNotificationCenter defaultCenter] postNotificationName:CCMPreferencesChangedNotification object:self];
}

- (NSDictionary *)selectedProject
{
    NSArray *selectedObjects = [allProjectsViewController selectedObjects];
    return (([selectedObjects count] == 1) ? [selectedObjects objectAtIndex:0] : nil);
}


- (NSString *)getValidatedURL
{
    NSString *url = [[self selectedProject] objectForKey:@"serverUrl"];
    CCMSyncConnection *connection = [[[CCMSyncConnection alloc] initWithURLString:url] autorelease];
    NSString *user = [url usernameFromURL];
    if(user != nil)
    {
        NSString *password = [passwordField stringValue];
        NSURLCredential *credential = [NSURLCredential credentialWithUser:user password:password persistence:NSURLCredentialPersistenceNone];
        [connection setCredential:credential];
    }

    NSInteger statusCode = 0;
    @try
    {
        statusCode = [connection testConnection];
    }
    @catch(NSException *exception)
    {
        [[NSAlert alertWithText:ALERT_CONN_FAILURE_TITLE informativeText:[exception reason]] runModal];
        return nil;
    }

    if(statusCode != 200)
    {
        [[NSAlert alertWithText:ALERT_CONN_FAILURE_TITLE informativeText:[NSString stringWithFormat:(statusCode == 401) ? ALERT_CONN_FAILURE_STATUS401_INFO : ALERT_CONN_FAILURE_STATUS_INFO, (int)statusCode]] runModal];
        return nil;
    }
    if((statusCode == 200) && ([connection credential] != nil))
    {
        [CCMKeychainHelper setPassword:[[connection credential] password] forURLString:url error:NULL];
    }

    return url;
}

@end