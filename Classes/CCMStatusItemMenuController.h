
#import <Cocoa/Cocoa.h>
#import "CCMImageFactory.h"

@interface CCMStatusItemMenuController : NSObject 
{
	IBOutlet NSMenu				*statusMenu;
	IBOutlet CCMImageFactory	*imageFactory;
	NSStatusItem				*statusItem;
}

- (void)setMenu:(NSMenu *)aMenu;
- (void)setImageFactory:(CCMImageFactory *)anImageFactory;

- (NSStatusItem *)createStatusItem;
- (void)displayProjects:(NSArray *)projects;

- (IBAction)openProject:(id)sender;

@end
