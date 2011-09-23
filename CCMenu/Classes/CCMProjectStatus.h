
#import <Foundation/Foundation.h>

@interface CCMProjectStatus : NSObject 
{
    NSDictionary    *info;
}

- (id)initWithDictionary:(NSDictionary *)serverInfo;

- (NSDictionary *)info;

@end


@interface CCMProjectStatus(AttributesFromInfo)

- (NSString *)activity;
- (NSString *)lastBuildStatus;
- (NSString *)lastBuildLabel;
- (NSString *)lastBuildTime;
- (NSString *)webUrl;

@end

extern NSString *CCMSuccessStatus;
extern NSString *CCMFailedStatus;

extern NSString *CCMSleepingActivity;
extern NSString *CCMBuildingActivity;
