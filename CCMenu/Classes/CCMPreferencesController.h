
#import "CCMWindowController.h"
#import "CCMUserDefaultsManager.h"
#import "CCMProjectSheetController.h"
#import "CCMProjectNameSheetController.h"


@interface CCMPreferencesController : CCMWindowController <NSWindowDelegate>
{
	IBOutlet CCMUserDefaultsManager	*defaultsManager;
    
	IBOutlet NSPanel				*preferencesWindow;
	IBOutlet NSView					*paneHolderView;

	IBOutlet NSArrayController		*allProjectsViewController;
    IBOutlet CCMProjectSheetController *addProjectsController;
    IBOutlet CCMProjectNameSheetController *projectNameController;

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
- (IBAction)editProjectDisplayName:(id)sender;

- (IBAction)soundSelected:(id)sender;
- (NSArray *)availableSounds;

- (IBAction)preferencesChanged:(id)sender;
- (IBAction)activationPolicyChanged:(id)sender;

- (void)addProjectsForURL:(NSString *)url;

@end


extern NSString *CCMPreferencesChangedNotification;
