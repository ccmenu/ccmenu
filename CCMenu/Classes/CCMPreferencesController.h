
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
	
	IBOutlet NSPanel				*addProjectsSheet;
	IBOutlet NSTabView				*sheetTabView;
	IBOutlet NSComboBox				*serverUrlComboBox;
	IBOutlet NSMatrix				*serverTypeMatrix;
	IBOutlet NSProgressIndicator	*testServerProgressIndicator;
	IBOutlet NSArrayController		*chooseProjectsViewController;	
}

- (IBAction)showWindow:(id)sender;

- (IBAction)addProjects:(id)sender;
- (IBAction)historyURLSelected:(id)sender;
- (IBAction)serverTypeChanged:(id)sender;
- (IBAction)chooseProjects:(id)sender;
- (IBAction)closeAddProjectsSheet:(id)sender;

- (IBAction)removeProjects:(id)sender;

- (IBAction)switchPreferencesPane:(id)sender;
- (IBAction)preferencesChanged:(id)sender;

- (IBAction)updateIntervalChanged:(id)sender;
- (IBAction)checkForUpdateNow:(id)sender;

- (NSString *)determineServerURL;
- (NSArray *)convertProjectInfos:(NSArray *)projectInfos withServerUrl:(NSString *)serverUrl ;
- (void)addProjectsSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (IBAction)soundSelected:(id)sender;
- (NSArray *)availableSounds;

- (IBAction)openNotificationPreferences:(id)sender;

@end


extern NSString *CCMPreferencesChangedNotification;
