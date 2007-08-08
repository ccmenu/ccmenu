
#import <Cocoa/Cocoa.h>


@interface CCMImageFactory : NSObject 
{
}

- (NSImage *)imageForActivity:(NSString *)activity lastBuildStatus:(NSString *)status;
- (NSImage *)imageForUnavailableServer;

- (NSImage *)convertForMenuUse:(NSImage *)image;

@end
