
#import <Cocoa/Cocoa.h>


@interface CCMProject : NSObject <NSCopying>
{
	NSString		*name;
	NSDictionary	*info;
}

- (id)initWithName:(NSString *)aName;

- (void)updateWithInfo:(NSDictionary *)dictionary;

- (NSString *)name;

- (BOOL)isFailed;
- (BOOL)isBuilding;

@end

extern NSString *CCMSuccessStatus;
extern NSString *CCMFailedStatus;

extern NSString *CCMSleepingActivity;
extern NSString *CCMBuildingActivity;
