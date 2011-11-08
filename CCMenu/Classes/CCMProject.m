
#import "CCMProject.h"
#import "CCMProjectStatus.h"
#import "NSCalendarDate+CCMAdditions.h"


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
    [serverURL release];
	[status release];
    [statusError release];
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

- (void)setServerURL:(NSURL *)aURL
{
    [serverURL autorelease];
    serverURL = [aURL retain];
}

- (NSURL *)serverURL
{
    return serverURL;
}

- (void)setStatus:(CCMProjectStatus *)newStatus
{
    [status autorelease];
    status = [newStatus retain];
}

- (CCMProjectStatus *)status
{
    return status;
}

- (void)setStatusError:(NSString *)newError
{
    [statusError autorelease];
    statusError = [newError retain];
}

- (NSString *)statusError
{
    return statusError;
}


- (void)updateWithInfo:(NSDictionary *)dictionary
{
    if([dictionary objectForKey:@"errorString"] == nil)
    {
        [self setStatus:[[[CCMProjectStatus alloc] initWithDictionary:dictionary] autorelease]];
        [self setStatusError:nil];
    }
    else
    {
        [self setStatus:nil];
        [self setStatusError:[dictionary objectForKey:@"errorString"]];
    }
}

- (NSDictionary *)info
{
    return [status info];
}


- (void)setBuildDuration:(NSNumber *)duration
{
    [buildDuration autorelease];
    buildDuration = [duration retain];
}

- (NSNumber *)buildDuration
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
    if(buildDuration == nil)
        return nil;
    return [buildStartTime dateByAddingTimeInterval:[buildDuration doubleValue]];
}

- (BOOL)hasStatus
{
    return status != nil;
}

- (BOOL)isFailed
{
	return ([status lastBuildStatus] != nil) && ![[status lastBuildStatus] isEqualToString:CCMSuccessStatus];
}

- (BOOL)isBuilding
{
	return [[status activity] isEqualToString:CCMBuildingActivity];
}


@end
