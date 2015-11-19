
#import <Cocoa/Cocoa.h>

@class CCMProjectStatus;


@interface CCMImageFactory : NSObject 
{
}

- (NSImage *)imageForStatus:(CCMProjectStatus *)status;
- (NSImage *)imageForUnavailableServer;

- (NSImage *)convertForMenuUse:(NSImage *)image;
- (NSImage *)convertForItemUse:(NSImage *)image;

@end
