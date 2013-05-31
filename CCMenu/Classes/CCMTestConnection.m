
#import "CCMTestConnection.h"
#import "CCMServerStatusReader.h"

@implementation CCMTestConnection

- (void)dealloc
{
    [receivedData release];
    [receivedResponse release];
    [receivedError release];
    [super dealloc];
}

- (void)setUpForNewRequest
{
    [receivedData release];
    receivedData = [[NSMutableData alloc] init];
    [receivedResponse release];
    receivedResponse = nil;
    [receivedError release];
    receivedError = nil;
    didFinish = NO;
}

- (void)cleanUpAfterRequest
{
//    [urlConnection release];
//    urlConnection = nil;
}

- (BOOL)testConnection
{
    [self setUpForNewRequest];
    NSURLRequest *request = [NSURLRequest requestWithURL:serverUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    [NSURLConnection connectionWithRequest:request delegate:self];
    while(didFinish == NO)
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    if(receivedError != nil)
		[NSException raise:@"ConnectionException" format:@"%@", [self errorStringForError:receivedError]];
	return ([receivedResponse statusCode] == 200);
}

- (NSArray *)retrieveServerStatus
{
    [self setUpForNewRequest];
    NSURLRequest *request = [NSURLRequest requestWithURL:serverUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    [NSURLConnection connectionWithRequest:request delegate:self];
    while(didFinish == NO)
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    if(receivedError != nil)
        [NSException raise:@"ConnectionException" format:@"%@", [self errorStringForError:receivedError]];
    if([receivedResponse statusCode] != 200)
        [NSException raise:@"ConnectionException" format:@"%@", [self errorStringForResponse:receivedResponse]];
    CCMServerStatusReader *reader = [[[CCMServerStatusReader alloc] initWithServerResponse:receivedData] autorelease];
    NSError *parseError = nil;
    NSArray *infos = [reader readProjectInfos:&parseError];
    if(infos == nil)
        [NSException raise:@"ConnectionException" format:@"%@", [self errorStringForParseError:parseError]];
    return infos;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSURLCredential *credential = [delegate connection:self willUseCredential:[challenge proposedCredential] forMessage:[[challenge protectionSpace] realm]];
    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    receivedResponse = [response retain];
    // doc says this could be called multiple times, so we reset data
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    didFinish = YES;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)anError
{
    receivedError = [anError retain];
}

@end
