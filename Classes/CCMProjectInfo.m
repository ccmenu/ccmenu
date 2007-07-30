
#import "CCMProjectInfo.h"
#import "NSCalendarDate+CCMAdditions.h"


NSString *CCMPassedStatus = @"Success";
NSString *CCMFailedStatus = @"Failure";

static NSString *XML_DATE_FORMAT = @"%Y-%m-%dT%H:%M:%S";

@implementation CCMProjectInfo

+ (NSArray *)infosFromXmlData:(NSData *)xml
{
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:xml options:NSXMLNodeOptionsNone error:nil];
	NSArray *projectElements = [doc nodesForXPath:@"//Project" error:nil];
	
	NSMutableArray *infoArray = [NSMutableArray array];
	NSEnumerator *projectEnum = [projectElements objectEnumerator];
	NSXMLElement *element = nil;
	while((element = [projectEnum nextObject]) != nil)
	{
		NSString *projectName = [[element attributeForName:@"name"] stringValue];
		NSString *buildStatus = [[element attributeForName:@"lastBuildStatus"] stringValue];
		NSString *builDateString = [[element attributeForName:@"lastBuildTime"] stringValue];
		NSCalendarDate *buildDate = [NSCalendarDate dateWithString:builDateString calendarFormat:XML_DATE_FORMAT];
		CCMProjectInfo *info = [[[self alloc] initWithProjectName:projectName buildStatus:buildStatus
													lastBuildDate:buildDate] autorelease];
		[infoArray addObject:info];
	}
	
	return infoArray;
}

- (id)initWithProjectName:(NSString *)aName buildStatus:(NSString *)aStatus lastBuildDate:(NSCalendarDate *)aDate
{
	[super init];
	projectName = [aName retain];
	buildStatus = [aStatus retain];
	lastBuildDate = [aDate retain];
	return self;
}


- (void)dealloc
{
	[projectName release];
	[buildStatus release];
	[lastBuildDate release];
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	return [self retain];
}

- (NSString *)projectName
{
	return projectName;
}

- (NSString *)buildStatus
{
	return buildStatus;
}

- (BOOL)isFailed
{
	return [buildStatus isEqualToString:CCMFailedStatus];
}

- (NSCalendarDate *)lastBuildDate
{
	return lastBuildDate;
}

- (NSString *)timeSinceLastBuild
{
	if(lastBuildDate == nil)
		return @"";
	return [[NSCalendarDate calendarDate] descriptionOfIntervalSinceDate:lastBuildDate];
}

@end
