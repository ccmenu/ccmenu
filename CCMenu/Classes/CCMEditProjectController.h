
#import <Cocoa/Cocoa.h>
#import "CCMUserDefaultsManager.h"


@interface CCMEditProjectController : NSObject
{
    IBOutlet CCMUserDefaultsManager	*defaultsManager;

    IBOutlet NSPanel                *editProjectSheet;
    IBOutlet NSTextField            *passwordField;
}

- (void)beginSheetForWindow:(NSWindow *)aWindow;
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (IBAction)closeSheet:(id)sender;

@end