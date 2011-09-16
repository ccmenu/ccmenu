
#import "CCMWindowController.h"
#import "CCMServerMonitor.h"


@interface CCMProjectWindowController : CCMWindowController 
{
    IBOutlet CCMServerMonitor   *serverMonitor;
	IBOutlet NSWindow			*window;
	IBOutlet NSTableView		*tableView;
	IBOutlet NSArrayController	*tableViewController;
    
    NSTimer *timer;
}

- (void)displayProjects:(id)sender;

- (IBAction)showWindow:(id)sender;

@end
