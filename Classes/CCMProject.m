
#import "CCMProject.h"
#import "NSCalendarDate+CCMAdditions.h"


NSString *CCMPassedStatus = @"Success";
NSString *CCMFailedStatus = @"Failure";

@implementation CCMProject

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

- (id)valueForUndefinedKey:(NSString *)key
{
	return [info objectForKey:key]; 
}

- (void)updateWithInfo:(NSDictionary *)dictionary
{
	[info autorelease];
	info = [dictionary copy];
}

- (NSString *)name
{
	return name;
}

- (BOOL)isFailed
{
	return [[self valueForKey:@"lastBuildStatus"] isEqualToString:CCMFailedStatus];
}

- (NSString *)timeSinceLastBuild
{
	NSCalendarDate *lastBuildDate = [self valueForKey:@"lastBuildTime"];
	if(lastBuildDate == nil)
		return @"";
	return [[NSCalendarDate calendarDate] descriptionOfIntervalSinceDate:lastBuildDate];
}

@end
