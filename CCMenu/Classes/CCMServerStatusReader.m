
#import "CCMServerStatusReader.h"


@implementation CCMServerStatusReader

- (id)initWithServerResponse:(NSData *)data
{
	self = [super init];
	responseData = [data copy];
	return self;
}

- (void)dealloc
{
	[responseData release];
	[super dealloc];
}

- (NSDate *)convertDateString:(NSString *)dateString
{
    if([dateString length] <= 19)
    {
        // assume old-style CruiseControl timestamp without timezone, assume local time
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        return [formatter dateFromString:dateString];
    }
    else
    {
        // assume some kind of ISO8601 date format
        NSISO8601DateFormatter *formatter = [[[NSISO8601DateFormatter alloc] init] autorelease];
        // Apple's parser doesn't seem to like fractional components; so we remove them
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[.,][0-9]+" options:0 error:NULL];
        dateString = [regex stringByReplacingMatchesInString:dateString options:0 range:NSMakeRange(0, [dateString length]) withTemplate:@""];
        return [formatter dateFromString:dateString];
    }
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

- (NSArray *)readProjectInfos:(NSError **)errorPtr
{
    NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithData:responseData options:NSXMLNodeOptionsNone error:errorPtr] autorelease];
    if(doc == nil)
        return nil;
    
    NSMutableArray *projectInfos = [NSMutableArray array];
    for(NSXMLElement *element in [doc nodesForXPath:@"//Project" error:nil])
	{
		NSDictionary *info = [NSMutableDictionary dictionary];
        for(NSXMLNode *attribute in [element attributes])
		{
			id value = [attribute stringValue];
			if([[attribute name] isEqualToString:@"lastBuildTime"])
				value = [self convertDateString:value];
			if([[attribute name] isEqualToString:@"webUrl"])
				value = [self fixUrlStringIfNecessary:value];
			[info setValue:value forKey:[attribute name]];
		}
		[projectInfos addObject:info];
	}
    return projectInfos;        
}

@end
