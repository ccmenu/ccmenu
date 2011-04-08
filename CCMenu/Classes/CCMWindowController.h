
#import <Cocoa/Cocoa.h>


@interface CCMWindowController : NSObject 
{
	NSDictionary	*toolbarDefinition;
}

- (NSToolbar *)createToolbarWithName:(NSString *)name;

@end
