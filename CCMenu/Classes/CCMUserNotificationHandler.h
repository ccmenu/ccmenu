
#import <Cocoa/Cocoa.h>


@interface CCMUserNotificationHandler : NSObject<NSUserNotificationCenterDelegate>
{
    IBOutlet CCMUserDefaultsManager *defaultsManager;
}

- (void)start;

- (void)openURLForNotification:(NSUserNotification *)notification;

@end
