
#import <Cocoa/Cocoa.h>
#import "CCMImageFactory.h"


@interface CCMBuildStatusTransformer : NSValueTransformer 
{
	CCMImageFactory *imageFactory;
}

- (void)setImageFactory:(CCMImageFactory *)anImageFactory;

@end

extern NSString *CCMBuildStatusTransformerName;
