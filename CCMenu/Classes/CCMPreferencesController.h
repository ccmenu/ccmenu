
#import "CCMWindowController.h"
#import "CCMUserDefaultsManager.h"
#import "CCMProjectSheetController.h"
#import <Sparkle/Sparkle.h>


@interface CCMPreferencesController : CCMWindowController
{
	IBOutlet CCMUserDefaultsManager	*defaultsManager;
#ifndef CCM_MAS_BUILD
	IBOutlet SUUpdater				*updater;
#endif
    
	IBOutlet NSPanel				*preferencesWindow;
	IBOutlet NSView					*paneHolderView;

	IBOutlet NSArrayController		*allProjectsViewController;
    IBOutlet CCMProjectSheetController *addProjectsController;

    IBOutlet NSView					*notificationPrefsView;
	IBOutlet NSArrayController		*soundNamesViewController;

	IBOutlet NSView					*advancedPrefsView;
    
    IBOutlet NSView					*projectsView;
    IBOutlet NSTableView            *projectsTableView;
 }

- (IBAction)showWindow:(id)sender;
- (IBAction)switchPreferencesPane:(id)sender;

- (NSDictionary *)selectedProject;
- (IBAction)addProjects:(id)sender;
- (IBAction)removeProjects:(id)sender;
- (IBAction)editProject:(id)sender;

- (IBAction)soundSelected:(id)sender;
- (NSArray *)availableSounds;

#ifndef CCM_MAS_BUILD
- (IBAction)openNotificationPreferences:(id)sender;
- (IBAction)updateIntervalChanged:(id)sender;
- (IBAction)checkForUpdateNow:(id)sender;
#endif

- (IBAction)preferencesChanged:(id)sender;


@end


extern NSString *CCMPreferencesChangedNotification;
