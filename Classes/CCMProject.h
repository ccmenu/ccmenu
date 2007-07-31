
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
- (NSString *)timeSinceLastBuild;

@end

extern NSString *CCMPassedStatus;
extern NSString *CCMFailedStatus;
