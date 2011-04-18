
#import <Cocoa/Cocoa.h>


@interface CCMWindowController : NSObject <NSToolbarDelegate>
{
	NSDictionary	*toolbarDefinition;
}

- (NSToolbar *)createToolbarWithName:(NSString *)name;

@end
