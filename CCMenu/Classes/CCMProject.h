
#import <Cocoa/Cocoa.h>
#import "CCMProjectStatus.h"


@interface CCMProject : NSObject <NSCopying>
{
	NSString            *name;
    NSURL               *serverURL;
    NSString            *displayName;
	CCMProjectStatus	*status;
    NSString            *statusError;
    NSNumber            *buildDuration;
    NSDate              *buildStartTime;
}

+ (CCMProject *)projectWithName:(NSString *)aName inFeed:(NSString *)aFeedURL;

- (id)initWithName:(NSString *)aName;
- (id)initWithName:(NSString *)aName andServerURL:(NSString *)urlString;

- (NSString *)name;

- (void)setServerURL:(NSURL *)aURL;
- (NSURL *)serverURL;

- (void)setDisplayName:(NSString *)aName;
- (NSString *)displayName;

- (void)updateWithInfo:(NSDictionary *)dictionary;
- (NSDictionary *)info;

- (void)setStatus:(CCMProjectStatus *)newStatus;
- (CCMProjectStatus *)status;

- (void)setStatusError:(NSString *)newError;
- (NSString *)statusError;

- (void)setBuildDuration:(NSNumber *)duration;
- (NSNumber *)buildDuration;

- (void)setBuildStartTime:(NSDate *)aTime;
- (NSDate *)buildStartTime;

- (NSDate *)estimatedBuildCompleteTime;

- (BOOL)hasStatus __unused;

@end

