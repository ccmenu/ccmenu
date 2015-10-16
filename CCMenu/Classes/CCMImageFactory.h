
#import <Cocoa/Cocoa.h>

@class CCMProjectStatus;


@interface CCMImageFactory : NSObject 
{
}

- (NSImage *)imageForStatus:(CCMProjectStatus *)status;
- (NSImage *)imageForUnavailableServer;

@end
