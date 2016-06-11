
#import <Cocoa/Cocoa.h>

@class CCMProjectStatus;
@class CCMUserDefaultsManager;


@interface CCMImageFactory : NSObject 
{
    IBOutlet CCMUserDefaultsManager *defaultsManager;
}

- (NSImage *)imageForStatus:(CCMProjectStatus *)status;
- (NSImage *)imageForUnavailableServer;

- (NSImage *)convertForMenuUse:(NSImage *)image;

@end
