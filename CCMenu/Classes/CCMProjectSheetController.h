
#import <Cocoa/Cocoa.h>
#import "CCMUserDefaultsManager.h"
#import "CCMConnection.h"


@interface CCMProjectSheetController : NSObject <CCMConnectionDelegate>
{
    IBOutlet CCMUserDefaultsManager	*defaultsManager;

    IBOutlet NSPanel				*projectSheet;
	IBOutlet NSTabView				*sheetTabView;

    IBOutlet NSComboBox				*urlComboBox;
	IBOutlet NSMatrix				*serverTypeMatrix;
	IBOutlet NSProgressIndicator	*progressIndicator;
    IBOutlet NSTextField            *statusField;
    IBOutlet NSButton               *authCheckBox;
    IBOutlet NSTextField            *userField;
    IBOutlet NSTextField            *passwordField;
    IBOutlet NSButton               *continueButton;

    IBOutlet NSArrayController      *allProjectsViewController;
    IBOutlet NSArrayController		*chooseProjectsViewController;
}


- (void)beginAddSheetForWindow:(NSWindow *)aWindow;
- (void)beginEditSheetWithProject:(NSDictionary *)aProject forWindow:(NSWindow *)aWindow;
- (void)beginSheetForWindow:(NSWindow *)aWindow contextInfo:(void *)contextInfo;
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (IBAction)historyURLSelected:(id)sender;
- (IBAction)serverDetectionChanged:(id)sender;
- (IBAction)useAuthenticationChanged:(id)sender;
- (IBAction)continueSheet:(id)sender;
- (IBAction)closeSheet:(id)sender;

- (NSString *)getValidatedURL;
- (NSString *)getCompletedAndValidatedURL;
- (NSInteger)checkURL:(NSString *)url;
- (void)showTestInProgress:(BOOL)flag;

@end
