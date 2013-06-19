
#import <Cocoa/Cocoa.h>
#import "CCMUserDefaultsManager.h"


@interface CCMEditProjectController : NSObject
{
    IBOutlet CCMUserDefaultsManager	*defaultsManager;

	IBOutlet NSArrayController		*allProjectsViewController;

    IBOutlet NSPanel                *editProjectSheet;
    IBOutlet NSTextField            *feedURLField;
    IBOutlet NSTextField            *passwordField;

	IBOutlet NSProgressIndicator	*progressIndicator;
    IBOutlet NSTextField            *statusField;
}

- (void)beginSheetForWindow:(NSWindow *)aWindow;
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (IBAction)closeSheet:(id)sender;

- (NSDictionary *)selectedProject;
- (NSString *)getValidatedURL;
- (void)showTestInProgress:(BOOL)flag;

@end