
#import "CCMConnection.h"
#import "CCMProject.h"


@implementation CCMConnection

static NSString *XML_DATE_FORMAT = @"%Y-%m-%dT%H:%M:%S";


- (id)initWithURL:(NSURL *)theServerUrl
{
	[super init];
	serverUrl = [theServerUrl retain];
	return self;
}

- (void)dealloc
{
	[serverUrl release];
	[super dealloc];
}

- (NSArray *)infosFromXmlData:(NSData *)xml
{
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:xml options:NSXMLNodeOptionsNone error:nil];	
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

- (NSArray *)getProjectInfos
{
	NSLog(@"url = %@", serverUrl);
	NSData *response = [serverUrl resourceDataUsingCache:NO];
	if((response == nil) || ([response length] == 0))
		[NSException raise:@"NotFoundException" format:@"Failed to get project info from %@" arguments:[serverUrl absoluteString]];
	NSString *responseString = [[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding];
	NSLog(@"response = %@", responseString);
	
	return [self infosFromXmlData:response];
}

@end
