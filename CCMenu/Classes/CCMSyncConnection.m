
#import "CCMSyncConnection.h"
#import "CCMServerStatusReader.h"

@implementation CCMSyncConnection

@synthesize runLoop;

- (id)initWithServerURL:(NSURL *)theServerUrl
{
    self = [super initWithServerURL:theServerUrl];
    runLoop = [NSRunLoop currentRunLoop];
    return self;
}

- (void)dealloc
{
    [receivedError release];
    [super dealloc];
}

- (void)setUpForNewRequest
{
    [super setUpForNewRequest];
    [receivedError release];
    receivedError = nil;
    didFinish = NO;
}

- (BOOL)testConnection
{
    [self setUpForNewRequest];
    NSURLRequest *request = [NSURLRequest requestWithURL:[self serverURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
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
    NSURLRequest *request = [NSURLRequest requestWithURL:[self serverURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
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

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    didFinish = YES;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)anError
{
    receivedError = [anError retain];
    didFinish = YES;
}

@end
