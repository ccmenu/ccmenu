
#import "CCMWindowController.h"


@interface CCMProjectWindowController : CCMWindowController 
{
	IBOutlet NSWindow			*window;
	IBOutlet NSTableView		*tableView;
	IBOutlet NSArrayController	*tableViewController;
}

- (void)displayProjects:(NSArray *)projects;

- (IBAction)showWindow:(id)sender;
- (IBAction)forceBuild:(id)sender;

@end
