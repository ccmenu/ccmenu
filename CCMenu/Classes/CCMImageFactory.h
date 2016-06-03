
#import <Cocoa/Cocoa.h>

@class CCMProjectStatus;


@interface CCMImageFactory : NSObject 
{
}

- (NSImage *)imageForStatus:(CCMProjectStatus *)status;
- (NSImage *)imageForStatus:(CCMProjectStatus *)status supportsSymbol:(BOOL)symbol;
- (NSImage *)imageForUnavailableServer;

- (NSImage *)convertForMenuUse:(NSImage *)image;

@end
