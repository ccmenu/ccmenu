
#import "CCMImageFactory.h"


@implementation CCMImageFactory

static CCMImageFactory *instance;

+ (id)imageFactory
{
	if(instance == nil)
		instance = [[CCMImageFactory alloc] init];
	return instance;
}

- (NSImage *)getImageForStatus:(NSString *)status
{
	NSString *name = [NSString stringWithFormat:@"icon-%@.gif", [status lowercaseString]];
	NSImage *image = [NSImage imageNamed:name];
	[image setScalesWhenResized:YES];
	[image setSize:NSMakeSize(13, 13)];
	return image;
}

@end
