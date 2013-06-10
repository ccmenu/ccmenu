
#import "CCMWindowController.h"
#import "CCMUserDefaultsManager.h"
#import <Sparkle/Sparkle.h>


@interface CCMPreferencesController : CCMWindowController 
{
	IBOutlet CCMUserDefaultsManager	*defaultsManager;
	IBOutlet SUUpdater				*updater;
	
	IBOutlet NSPanel				*preferencesWindow;
	IBOutlet NSView					*paneHolderView;
	IBOutlet NSArrayController		*allProjectsViewController;
    
	IBOutlet NSView					*projectsView;
	IBOutlet NSTextField			*versionField;
	
    IBOutlet NSView					*notificationPrefsView;
	IBOutlet NSArrayController		*soundNamesViewController;

	IBOutlet NSView					*advancedPrefsView;
    
    IBOutlet NSView                 *aboutView;
	
	IBOutlet NSPanel				*addProjectsSheet;
	IBOutlet NSTabView				*sheetTabView;
	IBOutlet NSComboBox				*serverUrlComboBox;
	IBOutlet NSMatrix				*serverTypeMatrix;
	IBOutlet NSProgressIndicator	*testServerProgressIndicator;
    IBOutlet NSBox                  *credentialBox;

    IBOutlet NSTextField            *userField;
    IBOutlet NSTextField            *passwordField;
	IBOutlet NSArrayController		*chooseProjectsViewController;

    IBOutlet NSPanel                *editProjectSheet;
    IBOutlet NSTextField            *editPasswordField;
}

- (IBAction)showWindow:(id)sender;

- (IBAction)addProjects:(id)sender;
- (IBAction)historyURLSelected:(id)sender;
- (IBAction)serverDetectionChanged:(id)sender;

- (IBAction)chooseProjects:(id)sender;
- (IBAction)closeAddProjectsSheet:(id)sender;
- (IBAction)removeProjects:(id)sender;
- (IBAction)editProject:(id)sender;
- (IBAction)closeEditProjectSheet:(id)sender;

- (IBAction)switchPreferencesPane:(id)sender;
- (IBAction)preferencesChanged:(id)sender;

- (IBAction)updateIntervalChanged:(id)sender;
- (IBAction)checkForUpdateNow:(id)sender;

- (NSString *)getValidatedURL;
- (NSString *)getCompletedAndValidatedURL;
- (NSInteger)checkURL:(NSString *)url;
- (NSArray *)convertProjectInfos:(NSArray *)projectInfos withServerUrl:(NSString *)serverUrl;
- (BOOL)isCredentialBoxVisible;
- (BOOL)didCredentialBoxBecomeVisible:(BOOL)previousState;

- (void)addProjectsSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)editProjectSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (IBAction)soundSelected:(id)sender;
- (NSArray *)availableSounds;

- (IBAction)openNotificationPreferences:(id)sender;

@end


extern NSString *CCMPreferencesChangedNotification;
