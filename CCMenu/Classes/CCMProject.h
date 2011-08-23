
#import <Cocoa/Cocoa.h>


@interface CCMProject : NSObject <NSCopying>
{
	NSString		*name;
	NSDictionary	*info;
    NSTimeInterval  buildDuration;
    NSCalendarDate  *buildStartTime;
}

- (id)initWithName:(NSString *)aName;

- (NSString *)name;

- (void)updateWithInfo:(NSDictionary *)dictionary;
- (NSDictionary *)info;

- (void)setBuildDuration:(NSTimeInterval)duration;
- (NSTimeInterval)buildDuration;

- (void)setBuildStartTime:(NSCalendarDate *)aTime;
- (NSCalendarDate *)buildStartTime;

- (NSCalendarDate *)estimatedBuildCompleteTime;

- (BOOL)isFailed;
- (BOOL)isBuilding;

@end

@interface CCMProject(AttributesFromInfo)

- (NSString *)activity;
- (NSString *)lastBuildStatus;
- (NSString *)lastBuildLabel;
- (NSString *)lastBuildTime;
- (NSString *)webUrl;
- (NSString *)errorString;

@end

extern NSString *CCMSuccessStatus;
extern NSString *CCMFailedStatus;

extern NSString *CCMSleepingActivity;
extern NSString *CCMBuildingActivity;
