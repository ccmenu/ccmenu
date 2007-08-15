
#import <Cocoa/Cocoa.h>


@interface CCMPreferencesController : NSObject 
{
	NSUserDefaults	*userDefaults;
	
	IBOutlet NSPanel				*preferencesWindow;
	IBOutlet NSArrayController		*allProjectsViewController;
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

- (IBAction)preferencesChanged:(id)sender;

- (NSURL *)getServerURL;
- (void)addProjectsSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

@end


extern NSString *CCMDefaultsProjectListKey;
extern NSString *CCMDefaultsProjectEntryNameKey;
extern NSString *CCMDefaultsProjectEntryServerUrlKey;

extern NSString *CCMDefaultsPollIntervalKey;

extern NSString *CCMPreferencesChangedNotification;
