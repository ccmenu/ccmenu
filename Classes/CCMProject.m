
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
	infoKeys = [[NSSet setWithObjects:@"activity", @"lastBuildStatus", @"lastBuildLabel", @"lastBuildTime", @"webUrl", nil] retain];
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
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	return [self retain];
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

- (NSString *)name
{
	return name;
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
