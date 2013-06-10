#import "CCMEditProjectController.h"
#import "CCMKeychainHelper.h"
#import "CCMPreferencesController.h"


@implementation CCMEditProjectController

- (void)beginSheetForWindow:(NSWindow *)aWindow
{
    NSString *password = [CCMKeychainHelper passwordForURLString:@"http://dev@localhost:4567" error:NULL];
    [passwordField setStringValue:(password != nil) ? password : @""];
    [NSApp beginSheet:editProjectSheet modalForWindow:aWindow modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)closeSheet:(id)sender
{
    [NSApp endSheet:editProjectSheet returnCode:[sender tag]];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [editProjectSheet orderOut:self];
    if(returnCode == 0)
        return;

    [[NSNotificationCenter defaultCenter] postNotificationName:CCMPreferencesChangedNotification object:self];
}


@end