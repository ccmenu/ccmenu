
#import <Cocoa/Cocoa.h>
#import "CCMImageFactory.h"
#import "CCMServerMonitor.h"


@interface CCMStatusItemMenuController : NSObject 
{
    IBOutlet CCMServerMonitor   *serverMonitor;
	IBOutlet CCMImageFactory	*imageFactory;
	IBOutlet NSMenu				*statusMenu;

	NSStatusItem	*statusItem;
    NSTimer         *timer;

}

- (NSStatusItem *)statusItem;

- (void)displayProjects:(id)sender;
- (IBAction)openProject:(id)sender;

@end
