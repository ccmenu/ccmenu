
#import <OCMock/OCMock.h>
#import "CCMConnectionTest.h"
#import "CCMConnection.h"


@implementation CCMConnectionTest

#define RESPONSE_TEXT @"<Projects><Project name='connectfour' activity='Sleeping' lastBuildStatus='Success' lastBuildLabel='build.1' lastBuildTime='2007-07-18T18:44:48' webUrl='http://localhost:8080/dashboard/build/detail/connectfour'/></Projects>"


- (void)setUp
{
    connection = [[[CCMConnection alloc] init] autorelease];
    connectionMock = [OCMockObject partialMockForObject:connection];
}

- (id)responseMockWithStatusCode:(NSInteger)statusCode
{
    id responseMock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(statusCode)] statusCode];
    return responseMock;
}


- (void)testConnectionTestSuccessfulWhenServerReturns200StatusCode
{
    id responseMock = [self responseMockWithStatusCode:200];
    [[connectionMock stub] sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg setTo:responseMock] error:[OCMArg anyPointer]];
    
    BOOL success = [connection testConnection];

    STAssertTrue(success, @"Should have indicated success.");
}

- (void)testConnectionTestUnsuccessfulWhenServerReturns404StatusCode
{
    id responseMock = [self responseMockWithStatusCode:404];
    [[connectionMock stub] sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg setTo:responseMock] error:[OCMArg anyPointer]];
    
    BOOL success = [connection testConnection];
    
    STAssertFalse(success, @"Should have indicated failure.");
}


- (void)testRetrievesStatusSynchronously
{
    id responseMock = [self responseMockWithStatusCode:200];
    NSData *responseData = [RESPONSE_TEXT dataUsingEncoding:NSASCIIStringEncoding];
    [[[connectionMock stub] andReturn:responseData] sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg setTo:responseMock] error:[OCMArg anyPointer]];
    
    NSArray *infos = [connection retrieveServerStatus];
    
    STAssertEqualObjects([[infos objectAtIndex:0] valueForKey:@"name"], @"connectfour", @"Should have returned info object corresponding to response");
}

- (void)testRaisesExceptionWhenRetrievingStatusCodeAndResponseStatusIsNot200OK
{
    id responseMock = [self responseMockWithStatusCode:500];
    
    [[[connectionMock stub] andReturn:[NSMutableData data]] sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg setTo:responseMock] error:[OCMArg anyPointer]];
    
    STAssertThrows([connection retrieveServerStatus], @"Should have raised an exception");
}


- (void)testRetrievesStatusAsynchronously
{
    NSURLConnection *dummyUrlConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"file:foo"]] delegate:nil startImmediately:NO];
    [[[connectionMock stub] andReturn:dummyUrlConnection] newAsynchronousRequest:[OCMArg any]];
    id responseMock = [self responseMockWithStatusCode:200];
    NSData *responseData = [RESPONSE_TEXT dataUsingEncoding:NSASCIIStringEncoding];
    [connection setDelegate:self];
    
    [connection requestServerStatus];
    [connection connection:dummyUrlConnection didReceiveResponse:responseMock];
    [connection connection:dummyUrlConnection didReceiveData:responseData];
    [connection connectionDidFinishLoading:dummyUrlConnection];

    STAssertEqualObjects([[recordedInfos objectAtIndex:0] valueForKey:@"name"], @"connectfour", @"Should have called delegate with info object corresponding to response");
}

- (void)connection:(CCMConnection *)connection didReceiveServerStatus:(NSArray *)projectInfoList
{
    recordedInfos = [[projectInfoList retain] autorelease];
}


- (void)testReportsErrorWhenAsychronousRetrievalOfStatusFailed
{
    NSURLConnection *dummyUrlConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"file:foo"]] delegate:nil startImmediately:NO];
    [[[connectionMock stub] andReturn:dummyUrlConnection] newAsynchronousRequest:[OCMArg any]];
    id responseMock = [self responseMockWithStatusCode:500];
    [connection setDelegate:self];
    
    [connection requestServerStatus];
    [connection connection:dummyUrlConnection didReceiveResponse:responseMock];
    [connection connectionDidFinishLoading:dummyUrlConnection];
    
    STAssertNotNil(recordedError, @"connectfour", @"Should have called delegate with error.");

}

- (void)connection:(CCMConnection *)connection hadTemporaryError:(NSString *)errorString
{
    recordedError = [[errorString retain] autorelease];
}


@end
