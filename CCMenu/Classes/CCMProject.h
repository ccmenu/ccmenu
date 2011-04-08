
#import <Cocoa/Cocoa.h>


@interface CCMProject : NSObject <NSCopying>
{
	NSString		*name;
	NSDictionary	*info;
}

- (id)initWithName:(NSString *)aName;

- (void)updateWithInfo:(NSDictionary *)dictionary;
- (NSDictionary *)info;

- (NSString *)name;

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
