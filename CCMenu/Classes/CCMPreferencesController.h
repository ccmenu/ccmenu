
#import "CCMWindowController.h"
#import "CCMUserDefaultsManager.h"
#import "CCMProjectSheetController.h"


@interface CCMPreferencesController : CCMWindowController
{
	IBOutlet CCMUserDefaultsManager	*defaultsManager;
    
	IBOutlet NSPanel				*preferencesWindow;
	IBOutlet NSView					*paneHolderView;

	IBOutlet NSArrayController		*allProjectsViewController;
    IBOutlet CCMProjectSheetController *addProjectsController;

    IBOutlet NSView					*projectsView;

    IBOutlet NSView					*appearanceView;

    IBOutlet NSView					*notificationPrefsView;
	IBOutlet NSArrayController		*soundNamesViewController;

	IBOutlet NSView					*advancedPrefsView;
    
}

- (IBAction)showWindow:(id)sender;
- (IBAction)switchPreferencesPane:(id)sender;

- (NSDictionary *)selectedProject;
- (IBAction)addProjects:(id)sender;
- (IBAction)removeProjects:(id)sender;
- (IBAction)editProject:(id)sender;

- (IBAction)soundSelected:(id)sender;
- (NSArray *)availableSounds;

- (IBAction)preferencesChanged:(id)sender;


@end


extern NSString *CCMPreferencesChangedNotification;
