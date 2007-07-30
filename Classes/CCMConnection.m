
#import "CCMConnection.h"
#import "CCMProjectInfo.h"


@implementation CCMConnection

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

- (NSArray *)getProjectInfos
{
	NSLog(@"url = %@", serverUrl);
	NSData *response = [serverUrl resourceDataUsingCache:NO];
	if((response == nil) || ([response length] == 0))
		[NSException raise:@"NotFoundException" format:@"Failed to get project info from %@" arguments:[serverUrl absoluteString]];
	NSString *responseString = [[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding];
	NSLog(@"response = %@", responseString);
	
	return [CCMProjectInfo infosFromXmlData:response];
}

@end
