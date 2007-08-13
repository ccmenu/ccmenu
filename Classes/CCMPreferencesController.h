
#import <Cocoa/Cocoa.h>


@interface CCMPreferencesController : NSObject 
{
	IBOutlet NSPanel				*preferencesWindow;
	IBOutlet NSOutlineView			*serverAndProjectView;
	
	IBOutlet NSPanel				*addServerSheet;
	IBOutlet NSComboBox				*serverUrlComboBox;
	IBOutlet NSMatrix				*serverTypeMatrix;
	IBOutlet NSProgressIndicator	*testServerProgressIndicator;
	
	IBOutlet NSTreeController		*serverAndProjectViewController;
}

- (IBAction)showWindow:(id)sender;

- (IBAction)addServer:(id)sender;
- (IBAction)removeServer:(id)sender;

- (IBAction)testServerConnection:(id)sender;
- (IBAction)closeAddServerSheet:(id)sender;

@end
