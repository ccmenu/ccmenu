
#import <Cocoa/Cocoa.h>
#import "CCMProject.h"


@interface CCMBuildNotificationFactory : NSObject 
{
}

- (NSNotification *)notificationForProject:(CCMProject *)project withOldStatus:(CCMProjectStatus *)oldStatus;

@end

extern NSString *CCMBuildStartNotification;
extern NSString *CCMBuildCompleteNotification;

extern NSString *CCMSuccessfulBuild;
extern NSString *CCMFixedBuild;
extern NSString *CCMBrokenBuild;
extern NSString *CCMStillFailingBuild;
