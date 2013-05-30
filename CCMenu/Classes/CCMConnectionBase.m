
#import "CCMConnectionBase.h"


@implementation CCMConnectionBase

@synthesize runLoop;
@synthesize delegate;


- (id)initWithServerURL:(NSURL *)theServerUrl
{
	self = [super init];
	serverUrl = [theServerUrl retain];
    runLoop = [NSRunLoop currentRunLoop];
	return self;
}

- (id)initWithURLString:(NSString *)theServerUrlAsString
{
	return [self initWithServerURL:[NSURL URLWithString:theServerUrlAsString]];
}

- (void)dealloc
{
	[serverUrl release];
    [super dealloc];
}

- (NSURL *)serverURL
{
    return serverUrl;
}

- (NSString *)errorStringForError:(NSError *)error
{
	return [NSString stringWithFormat:@"Failed to get status from %@: %@",
            [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey], [error localizedDescription]];
}

- (NSString *)errorStringForResponse:(NSHTTPURLResponse *)response
{
	return [NSString stringWithFormat:@"Failed to get status from %@: %@",
			[response URL], [NSHTTPURLResponse localizedStringForStatusCode:[response statusCode]]];
}

- (NSString *)errorStringForParseError:(NSError *)error
{
	return [NSString stringWithFormat:@"Failed to parse status from %@: %@ (Maybe the server is returning a temporary HTML error page instead of an XML document.)",
            [serverUrl description], [[error localizedDescription] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

@end
