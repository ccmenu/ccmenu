
#import "CCMWindowController.h"
#import "CCMUserDefaultsManager.h"
#import "CCMAddProjectsController.h"
#import "CCMEditProjectController.h"
#import <Sparkle/Sparkle.h>


@interface CCMPreferencesController : CCMWindowController
{
	IBOutlet CCMUserDefaultsManager	*defaultsManager;
	IBOutlet SUUpdater				*updater;
	
	IBOutlet NSPanel				*preferencesWindow;
	IBOutlet NSView					*paneHolderView;

	IBOutlet NSArrayController		*allProjectsViewController;
    IBOutlet CCMAddProjectsController *addProjectsController;
    IBOutlet CCMEditProjectController *editProjectController;

    IBOutlet NSView					*notificationPrefsView;
	IBOutlet NSArrayController		*soundNamesViewController;

	IBOutlet NSView					*advancedPrefsView;
    
    IBOutlet NSView                 *aboutView;
    IBOutlet NSView					*projectsView;
    IBOutlet NSTextField			*versionField;
 }

- (IBAction)showWindow:(id)sender;

- (IBAction)addProjects:(id)sender;
- (IBAction)removeProjects:(id)sender;
- (IBAction)editProject:(id)sender;

- (IBAction)switchPreferencesPane:(id)sender;
- (IBAction)preferencesChanged:(id)sender;

- (IBAction)updateIntervalChanged:(id)sender;
- (IBAction)checkForUpdateNow:(id)sender;

- (IBAction)soundSelected:(id)sender;
- (NSArray *)availableSounds;

- (IBAction)openNotificationPreferences:(id)sender;

@end


extern NSString *CCMPreferencesChangedNotification;
