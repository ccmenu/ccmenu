
#import <Cocoa/Cocoa.h>
#import "CCMUserDefaultsManager.h"


@interface CCMAddProjectsController : NSObject
{
    IBOutlet CCMUserDefaultsManager	*defaultsManager;

    IBOutlet NSPanel				*addProjectsSheet;
	IBOutlet NSTabView				*sheetTabView;

    IBOutlet NSComboBox				*serverUrlComboBox;
	IBOutlet NSMatrix				*serverTypeMatrix;
	IBOutlet NSProgressIndicator	*testServerProgressIndicator;
    IBOutlet NSTextField            *statusField;
    IBOutlet NSButton               *authCheckBox;
    IBOutlet NSTextField            *userField;
    IBOutlet NSTextField            *passwordField;

    IBOutlet NSArrayController		*chooseProjectsViewController;
}

- (void)beginSheetForWindow:(NSWindow *)aWindow;
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (IBAction)historyURLSelected:(id)sender;
- (IBAction)serverDetectionChanged:(id)sender;
- (IBAction)useAuthenticationChanged:(id)sender;
- (IBAction)chooseProjects:(id)sender;
- (IBAction)closeSheet:(id)sender;

- (NSString *)getValidatedURL;
- (NSString *)getCompletedAndValidatedURL;
- (NSInteger)checkURL:(NSString *)url;
- (NSArray *)convertProjectInfos:(NSArray *)projectInfos withServerUrl:(NSString *)serverUrl;
- (void)showTestInProgress:(BOOL)flag;

@end
