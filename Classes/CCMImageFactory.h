
#import <Cocoa/Cocoa.h>


@interface CCMImageFactory : NSObject 
{

}

+ (id)imageFactory;

- (NSImage *)getImageForStatus:(NSString *)status;

@end
