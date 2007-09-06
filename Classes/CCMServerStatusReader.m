
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

- (NSArray *)projectInfos
{
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:responseData options:NSXMLNodeOptionsNone error:nil];	
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
				value = [NSCalendarDate dateWithString:value calendarFormat:XML_DATE_FORMAT];
			[info setValue:value forKey:[attribute name]];
		}
		[infoArray addObject:info];
	}
	return infoArray;
}

@end
