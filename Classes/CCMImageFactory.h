
#import <Cocoa/Cocoa.h>


@interface CCMImageFactory : NSObject 
{
}

- (NSImage *)imageForActivity:(NSString *)activity lastBuildStatus:(NSString *)status;
- (NSString *)imageNameForActivity:(NSString *)activity lastBuildStatus:(NSString *)status;

- (NSImage *)pausedImage;

- (NSImage *)convertForMenuUse:(NSImage *)image;

@end
