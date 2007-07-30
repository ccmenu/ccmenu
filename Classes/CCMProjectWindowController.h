
#import <Cocoa/Cocoa.h>


@interface CCMProjectWindowController : NSObject 
{
	IBOutlet NSWindow			*window;
	IBOutlet NSTableView		*tableView;
	IBOutlet NSArrayController	*projectController;
}

- (IBAction)showWindow:(id)sender;
- (IBAction)forceBuild:(id)sender;

- (void)displayProjectInfos:(NSArray *)projectInfos;

@end
