
#import <Cocoa/Cocoa.h>

@interface CCMStatusBarMenuController : NSObject 
{
	IBOutlet NSMenu	*statusMenu;
	NSStatusItem	*statusItem;
}

- (void)setMenu:(NSMenu *)aMenu;

- (NSStatusItem *)createStatusItem;
- (void)displayProjectInfos:(NSArray *)projectInfos;
- (NSImage *)getImageForStatus:(NSString *)status;

- (IBAction)openProject:(id)sender;

@end
