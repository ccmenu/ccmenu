
#import "CCMProject.h"


@implementation CCMProject

- (id)initWithName:(NSString *)aName
{
	self = [super init];
	name = [aName retain];
	return self;
}

- (id)initWithName:(NSString *)aName andServerURL:(NSString *)urlString
{
    [self initWithName:aName];
    [self setServerURL:[NSURL URLWithString:urlString]];
    return self;
}

- (void)dealloc
{
	[name release];
    [serverURL release];
    [displayName release];
	[status release];
    [statusError release];
    [buildStartTime release];
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	return [self retain];
}

- (BOOL)isEqual:(id)other
{
    return [name isEqualToString:[other name]] && [serverURL isEqual:[other serverURL]];
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

- (void)setDisplayName:(NSString *)aName
{
    [displayName autorelease];
    displayName = [aName retain];
}

- (NSString *)displayName
{
    return displayName;
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

- (NSCalendarDate *)buildStartTime
{
    return buildStartTime;
}

- (NSCalendarDate *)estimatedBuildCompleteTime
{
    if(buildDuration == nil)
        return nil;
    return [buildStartTime dateByAddingTimeInterval:[buildDuration doubleValue]];
}

- (BOOL)hasStatus __unused // actually used via an NSSortDescriptor
{
    return status != nil;
}

@end
