
#import "CCMConnection.h"
#import "CCMServerStatusReader.h"


@implementation CCMConnection

- (void)requestServerStatus
{
	if(urlConnection != nil)
		return;
	NSURLRequest *request = [NSURLRequest requestWithURL:serverUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    urlConnection = [[NSURLConnection connectionWithRequest:request delegate:self] retain];
	receivedData = [[NSMutableData data] retain];
}

- (void)cleanUpAfterStatusRequest
{
	[urlConnection release];
    [receivedData release];
	urlConnection = nil;
	receivedData = nil;
}

- (void)cancelStatusRequest
{
	if(urlConnection == nil)
		return;
	[urlConnection cancel];
	[self cleanUpAfterStatusRequest];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
//    if([challenge previousFailureCount] == 0)
//    {
//        NSURLCredential *credential = [NSURLCredential credentialWithUser:@"dev" password:@"passw0rd" persistence:NSURLCredentialPersistenceForSession];
//        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
//    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// this could be called multiple times, due to redirects for example, so we reset data
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

@end
