
#import <Cocoa/Cocoa.h>


@interface CCMBuildNotificationFactory : NSObject 
{
}


- (NSNotification *)buildNotificationForOldProjectInfo:(NSDictionary *)oldInfo andNewProjectInfo:(NSDictionary *)newInfo;

@end

extern NSString *CCMBuildStartNotification;
extern NSString *CCMBuildCompleteNotification;

extern NSString *CCMSuccessfulBuild;
extern NSString *CCMFixedBuild;
extern NSString *CCMBrokenBuild;
extern NSString *CCMStillFailingBuild;
