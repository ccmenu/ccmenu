
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

- (void)testRetrievesStatusAsynchronously
{
    id urlConnectionMock = [OCMockObject mockForClass:[NSURLConnection class]];
    [[[urlConnectionMock stub] andReturn:urlConnectionMock] connectionWithRequest:[OCMArg any] delegate:[OCMArg any]];

    [connection setDelegate:self];
    [connection requestServerStatus];
    [connection connection:urlConnectionMock didReceiveResponse:[self responseMockWithStatusCode:200]];
    [connection connection:urlConnectionMock didReceiveData:[RESPONSE_TEXT dataUsingEncoding:NSASCIIStringEncoding]];
    [connection connectionDidFinishLoading:urlConnectionMock];

    STAssertEqualObjects([[recordedInfoList objectAtIndex:0] valueForKey:@"name"], @"connectfour", @"Should have called delegate with info object corresponding to response");
}

- (void)connection:(CCMConnection *)connection didReceiveServerStatus:(NSArray *)projectInfoList
{
    recordedInfoList = [[projectInfoList retain] autorelease];
}


- (void)testReportsErrorWhenAsychronousRetrievalOfStatusFailed
{
    id urlConnectionMock = [OCMockObject mockForClass:[NSURLConnection class]];
    [[[urlConnectionMock stub] andReturn:urlConnectionMock] connectionWithRequest:[OCMArg any] delegate:[OCMArg any]];

    [connection setDelegate:self];
    [connection requestServerStatus];
    [connection connection:urlConnectionMock didReceiveResponse:[self responseMockWithStatusCode:500]];
    [connection connectionDidFinishLoading:urlConnectionMock];

    STAssertNotNil(recordedError, @"connectfour", @"Should have called delegate with error.");

}

- (void)connection:(CCMConnection *)connection hadTemporaryError:(NSString *)errorString
{
    recordedError = [[errorString retain] autorelease];
}


@end
