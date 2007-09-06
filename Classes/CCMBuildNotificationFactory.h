
#import <Cocoa/Cocoa.h>
#import "CCMProject.h"


@interface CCMBuildNotificationFactory : NSObject 
{
}

- (NSNotification *)buildCompleteNotificationForProject:(CCMProject *)project andNewInfo:(NSDictionary *)info;

@end

extern NSString *CCMBuildCompleteNotification;
extern NSString *CCMSuccessfulBuild;
extern NSString *CCMFixedBuild;
extern NSString *CCMBrokenBuild;
extern NSString *CCMStillFailingBuild;
