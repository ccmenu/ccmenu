
#import <Cocoa/Cocoa.h>


@interface CCMPreferencesController : NSObject 
{
	IBOutlet NSPanel				*preferencesWindow;
	
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

@end
