
#import "CCMTestConnection.h"

@implementation CCMTestConnection

- (BOOL)testConnection
{
    statusCode = 0;
    error = nil;
	didFinish = NO;
    NSURLRequest *request = [NSURLRequest requestWithURL:serverUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    [NSURLConnection connectionWithRequest:request delegate:self];
    while(didFinish == NO)
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    if(error != nil)
    {
        [error autorelease];
		[NSException raise:@"ConnectionException" format:@"%@", [self errorStringForError:error]];
    }
	return (statusCode >= 200 && statusCode != 404 && statusCode < 500);
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSURLCredential *credential = [delegate connection:self willUseCredential:[challenge proposedCredential] forMessage:[[challenge protectionSpace] realm]];
    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    statusCode = [(NSHTTPURLResponse *)response statusCode];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    didFinish = YES;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)anError
{
    error = [anError retain];
}

@end
