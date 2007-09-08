
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
	IBOutlet NSView					*notificationPrefsView;
	IBOutlet NSView					*advancedPrefsView;
	IBOutlet NSTextField			*versionField;
	
	IBOutlet NSPanel				*addProjectsSheet;
	IBOutlet NSTabView				*sheetTabView;
	IBOutlet NSComboBox				*serverUrlComboBox;
	IBOutlet NSMatrix				*serverTypeMatrix;
	IBOutlet NSProgressIndicator	*testServerProgressIndicator;
	IBOutlet NSArrayController		*chooseProjectsViewController;	
}

- (IBAction)showWindow:(id)sender;

- (IBAction)addProjects:(id)sender;
- (IBAction)chooseProjects:(id)sender;
- (IBAction)closeAddProjectsSheet:(id)sender;

- (IBAction)removeProjects:(id)sender;

- (IBAction)switchPreferencesPane:(id)sender;
- (IBAction)preferencesChanged:(id)sender;

- (IBAction)updateIntervalChanged:(id)sender;
- (IBAction)checkForUpdateNow:(id)sender;

- (NSURL *)getServerURL;
- (void)addProjectsSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

@end


extern NSString *CCMPreferencesChangedNotification;
