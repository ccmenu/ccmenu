
#import "CCMConnection.h"
#import "CCMServerStatusReader.h"


@implementation CCMConnection

@synthesize serverURL;
@synthesize delegate;

- (id)initWithServerURL:(NSURL *)theServerUrl
{
    self = [super init];
    serverURL = [theServerUrl copy];
    return self;
}

- (id)initWithURLString:(NSString *)theServerUrlAsString
{
    return [self initWithServerURL:[NSURL URLWithString:theServerUrlAsString]];
}

- (void)dealloc
{
    [serverURL release];
    [receivedData release];
    [receivedResponse release];
    [urlConnection release]; // just in case
    [super dealloc];
}

- (void)setUpForNewRequest
{
    [receivedData release];
    receivedData = [[NSMutableData alloc] init];
    [receivedResponse release];
    receivedResponse = nil;
}

- (void)cleanUpAfterStatusRequest
{
	[urlConnection release];
	urlConnection = nil;
}

- (void)requestServerStatus
{
    if(urlConnection != nil)
        return;
    NSURLRequest *request = [NSURLRequest requestWithURL:serverURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    urlConnection = [[NSURLConnection connectionWithRequest:request delegate:self] retain];
    receivedData = [[NSMutableData data] retain];
}

- (void)cancelStatusRequest
{
	if(urlConnection == nil)
		return;
	[urlConnection cancel];
	[self cleanUpAfterStatusRequest];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if([[challenge proposedCredential] hasPassword] && ([challenge previousFailureCount] == 0))
    {
        [[challenge sender] useCredential:[challenge proposedCredential] forAuthenticationChallenge:challenge];
    }
    else
    {
        NSURLCredential *credential = [delegate connection:self credentialForAuthenticationChallange:challenge];
        if(credential != nil)
            [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        else
            [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    receivedResponse = (NSHTTPURLResponse *)[response retain];
    // doc says this could be called multiple times, so we reset data
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	CCMServerStatusReader *reader = [[[CCMServerStatusReader alloc] initWithServerResponse:receivedData] autorelease];
    [self cleanUpAfterStatusRequest];
    NSError *error = nil;
    NSArray *infos = [reader readProjectInfos:&error];
    if(infos != nil)
        [delegate connection:self didReceiveServerStatus:infos];
    else
        [delegate connection:self hadTemporaryError:[self errorStringForParseError:error]];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self cleanUpAfterStatusRequest];
	[delegate connection:self hadTemporaryError:[self errorStringForError:error]];
}

- (NSString *)errorStringForError:(NSError *)error
{
    NSString *description = [error localizedDescription];;
    if([[error domain] isEqualToString:NSURLErrorDomain] && ([error code] == NSURLErrorUserCancelledAuthentication))
    {
        description = @"Server requires authentication and there is a problem with the credentials. Please verify the connection details for the project.";
    }
    return [NSString stringWithFormat:@"Failed to get status from %@: %@",
             [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey],
             description];
}

- (NSString *)errorStringForResponse:(NSHTTPURLResponse *)response
{
    return [NSString stringWithFormat:@"Failed to get status from %@: %@",
             [response URL],
             [NSHTTPURLResponse localizedStringForStatusCode:[response statusCode]]];
}

- (NSString *)errorStringForParseError:(NSError *)error
{
    return [NSString stringWithFormat:@"Failed to parse status from %@: %@ (Maybe the server is returning a temporary HTML error page instead of an XML document.)",
             [serverURL description],
             [[error localizedDescription] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

@end
