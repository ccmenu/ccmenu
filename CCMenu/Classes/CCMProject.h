
#import <Cocoa/Cocoa.h>
#import "CCMProjectStatus.h"


@interface CCMProject : NSObject <NSCopying>
{
	NSString            *name;
    NSURL               *serverURL;
	CCMProjectStatus	*status;
    NSString            *statusError;
    NSNumber            *buildDuration;
    NSCalendarDate      *buildStartTime;
}

- (id)initWithName:(NSString *)aName;

- (NSString *)name;

- (void)setServerURL:(NSURL *)aURL;
- (NSURL *)serverURL;

- (void)updateWithInfo:(NSDictionary *)dictionary;
- (NSDictionary *)info;

- (void)setStatus:(CCMProjectStatus *)newStatus;
- (CCMProjectStatus *)status;

- (void)setStatusError:(NSString *)newError;
- (NSString *)statusError;

- (void)setBuildDuration:(NSNumber *)duration;
- (NSNumber *)buildDuration;

- (void)setBuildStartTime:(NSCalendarDate *)aTime;
- (NSCalendarDate *)buildStartTime;

- (NSCalendarDate *)estimatedBuildCompleteTime;

- (BOOL)hasStatus;
- (BOOL)isFailed;
- (BOOL)isBuilding;

@end

