
#import "CCMProject.h"
#import "NSCalendarDate+CCMAdditions.h"


NSString *CCMSuccessStatus = @"Success";
NSString *CCMFailedStatus = @"Failure";

NSString *CCMSleepingActivity = @"Sleeping";
NSString *CCMBuildingActivity = @"Building";

static NSSet *infoKeys;


@implementation CCMProject

+ (void)initialize
{
	infoKeys = [[NSSet setWithObjects:@"activity", @"lastBuildStatus", @"lastBuildLabel", @"lastBuildTime", 
                 @"webUrl", @"errorString", nil] retain];
}

- (id)initWithName:(NSString *)aName
{
	[super init];
	name = [aName retain];
	return self;
}

- (void)dealloc
{
	[name release];
	[info release];
    [buildStartTime release];
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	return [self retain];
}


- (NSString *)name
{
	return name;
}


- (void)updateWithInfo:(NSDictionary *)dictionary
{
	[info autorelease];
	info = [dictionary copy];
}

- (NSDictionary *)info
{
	return info;
}


- (void)setBuildDuration:(NSTimeInterval)duration
{
    buildDuration = duration;
}

- (NSTimeInterval)buildDuration
{   
    return buildDuration;
}

- (void)setBuildStartTime:(NSCalendarDate *)aTime
{
    [buildStartTime autorelease];
    buildStartTime = [aTime retain];
}

- (NSDate *)buildStartTime
{
    return buildStartTime;
}

- (NSCalendarDate *)estimatedBuildCompleteTime
{
    if(buildDuration == 0)
        return nil;
    return [buildStartTime dateByAddingTimeInterval:buildDuration];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
	if([infoKeys containsObject:NSStringFromSelector(selector)])
		return [super methodSignatureForSelector:@selector(name)];
	return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
	NSString *value = [info objectForKey:NSStringFromSelector([invocation selector])];
	[invocation setReturnValue:&value];
}

- (id)valueForUndefinedKey:(NSString *)key
{
	return [info objectForKey:key]; 
}


- (BOOL)isFailed
{
	return ([self lastBuildStatus] != nil) && ![[self lastBuildStatus] isEqualToString:CCMSuccessStatus];
}

- (BOOL)isBuilding
{
	return [[self activity] isEqualToString:CCMBuildingActivity];
}


@end
