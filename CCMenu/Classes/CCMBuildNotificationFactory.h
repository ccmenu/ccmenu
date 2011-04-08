
#import <Cocoa/Cocoa.h>


@interface CCMBuildNotificationFactory : NSObject 
{
}

- (NSNotification *)buildCompleteNotificationForOldProjectInfo:(NSDictionary *)oldInfo andNewProjectInfo:(NSDictionary *)newInfo;

@end

extern NSString *CCMBuildCompleteNotification;
extern NSString *CCMSuccessfulBuild;
extern NSString *CCMFixedBuild;
extern NSString *CCMBrokenBuild;
extern NSString *CCMStillFailingBuild;
