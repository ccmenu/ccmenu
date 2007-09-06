
#import "CCMServerStatusReader.h"


@implementation CCMServerStatusReader

static NSString *XML_DATE_FORMAT = @"%Y-%m-%dT%H:%M:%S";


- (id)initWithServerResponse:(NSData *)data
{
	[super init];
	responseData = [data copy];
	return self;
}

- (void)dealloc
{
	[responseData release];
	[super dealloc];
}

- (NSCalendarDate *)convertDateString:(NSString *)dateString
{
	return [NSCalendarDate dateWithString:dateString calendarFormat:XML_DATE_FORMAT];
}

- (NSString *)fixUrlStringIfNecessary:(NSString *)urlString
{
	// The following is a workaround for a CruiseControl.rb bug
	NSRange ppRange = [urlString rangeOfString:@"projectsprojects"];
	if(ppRange.length > 0)
	{
		NSMutableString *copy = [NSMutableString stringWithString:urlString];
		[copy replaceCharactersInRange:ppRange withString:@"projects"];
		urlString = copy;
	}
	return urlString;
}


- (NSArray *)projectInfos
{
    NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithData:responseData options:NSXMLNodeOptionsNone error:nil] autorelease];	
	NSMutableArray *infoArray = [NSMutableArray array];
	NSEnumerator *projectEnum = [[doc nodesForXPath:@"//Project" error:nil] objectEnumerator];
	NSXMLElement *element = nil;
	while((element = [projectEnum nextObject]) != nil)
	{
		NSDictionary *info = [NSMutableDictionary dictionary];
		NSEnumerator *attributeEnum = [[element attributes] objectEnumerator];
		NSXMLNode *attribute = nil;
		while((attribute = [attributeEnum nextObject]) != nil)
		{
			id value = [attribute stringValue];
			if([[attribute name] isEqualToString:@"lastBuildTime"])
				value = [self convertDateString:value];
			if([[attribute name] isEqualToString:@"webUrl"])
				value = [self fixUrlStringIfNecessary:value];
			[info setValue:value forKey:[attribute name]];
		}
		[infoArray addObject:info];
	}
	return infoArray;
}

@end
