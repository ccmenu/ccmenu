
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

- (void)setMenu:(NSMenu *)aMenu;
- (void)setImageFactory:(CCMImageFactory *)anImageFactory;

- (NSStatusItem *)createStatusItem;
- (void)displayProjects:(id)sender;

- (IBAction)openProject:(id)sender;

@end
