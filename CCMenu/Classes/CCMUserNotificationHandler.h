
#import <Cocoa/Cocoa.h>


@interface CCMUserNotificationHandler : NSObject<NSUserNotificationCenterDelegate>
{
    IBOutlet CCMUserDefaultsManager *defaultsManager;
}

- (void)start;

@end
