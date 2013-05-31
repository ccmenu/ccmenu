
#import <OCMock/OCMock.h>
#import "CCMTestConnection.h"
#import "CCMTestConnectionTest.h"


@implementation CCMTestConnectionTest

#define RESPONSE_TEXT @"<Projects><Project name='connectfour' activity='Sleeping' lastBuildStatus='Success' lastBuildLabel='build.1' lastBuildTime='2007-07-18T18:44:48' webUrl='http://localhost:8080/dashboard/build/detail/connectfour'/></Projects>"

- (id)responseMockWithStatusCode:(NSInteger)statusCode
{
    id mock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[mock stub] andReturnValue:OCMOCK_VALUE(statusCode)] statusCode];
    return mock;
}


- (void)testConnectionTestSuccessfulWhenServerReturns200StatusCode
{
    CCMTestConnection *connection = [[[CCMTestConnection alloc] initWithURLString:@"http://dummy"] autorelease];
    
    id urlConnectionMock = [OCMockObject mockForClass:[NSURLConnection class]];
    [[[urlConnectionMock stub] andReturn:urlConnectionMock] connectionWithRequest:[OCMArg any] delegate:connection];

    id runLoopMock = [OCMockObject mockForClass:[NSRunLoop class]];
    void (^callbacks)(NSInvocation *) = ^(NSInvocation *invocation) {
        [connection connection:urlConnectionMock didReceiveResponse:[self responseMockWithStatusCode:200]];
        [connection connectionDidFinishLoading:urlConnectionMock];
    };
    [[[runLoopMock stub] andDo:callbacks] runMode:NSDefaultRunLoopMode beforeDate:[OCMArg any]];
    [connection setRunLoop:runLoopMock];

    BOOL success = [connection testConnection];
    
    STAssertTrue(success, @"Should have indicated success.");
}

- (void)testConnectionTestUnsuccessfulWhenServerReturns404StatusCode
{
    CCMTestConnection *connection = [[[CCMTestConnection alloc] initWithURLString:@"http://dummy"] autorelease];

    id urlConnectionMock = [OCMockObject mockForClass:[NSURLConnection class]];
    [[[urlConnectionMock stub] andReturn:urlConnectionMock] connectionWithRequest:[OCMArg any] delegate:connection];

    id runLoopMock = [OCMockObject mockForClass:[NSRunLoop class]];
    void (^callbacks)(NSInvocation *) = ^(NSInvocation *invocation) {
        [connection connection:urlConnectionMock didReceiveResponse:[self responseMockWithStatusCode:404]];
        [connection connectionDidFinishLoading:urlConnectionMock];
    };
    [[[runLoopMock stub] andDo:callbacks] runMode:NSDefaultRunLoopMode beforeDate:[OCMArg any]];
    [connection setRunLoop:runLoopMock];

    BOOL success = [connection testConnection];
    
    STAssertFalse(success, @"Should have indicated failure.");
}

- (void)testRetrievesStatusSynchronously
{
    CCMTestConnection *connection = [[[CCMTestConnection alloc] initWithURLString:@"http://dummy"] autorelease];

    id urlConnectionMock = [OCMockObject mockForClass:[NSURLConnection class]];
    [[[urlConnectionMock stub] andReturn:urlConnectionMock] connectionWithRequest:[OCMArg any] delegate:connection];

    id runLoopMock = [OCMockObject mockForClass:[NSRunLoop class]];
    void (^callbacks)(NSInvocation *) = ^(NSInvocation *invocation) {
        [connection connection:urlConnectionMock didReceiveResponse:[self responseMockWithStatusCode:200]];
        [connection connection:urlConnectionMock didReceiveData:[RESPONSE_TEXT dataUsingEncoding:NSASCIIStringEncoding]];
        [connection connectionDidFinishLoading:urlConnectionMock];
    };
    [[[runLoopMock stub] andDo:callbacks] runMode:NSDefaultRunLoopMode beforeDate:[OCMArg any]];
    [connection setRunLoop:runLoopMock];

    NSArray *infos = [connection retrieveServerStatus];

    STAssertEqualObjects([[infos objectAtIndex:0] valueForKey:@"name"], @"connectfour", @"Should have returned info object corresponding to response");
}

- (void)testRaisesExceptionWhenRetrievingStatusAndResponseStatusCodeIsNot200OK
{
    CCMTestConnection *connection = [[[CCMTestConnection alloc] initWithURLString:@"http://dummy"] autorelease];

    id urlConnectionMock = [OCMockObject mockForClass:[NSURLConnection class]];
    [[[urlConnectionMock stub] andReturn:urlConnectionMock] connectionWithRequest:[OCMArg any] delegate:connection];

    id runLoopMock = [OCMockObject mockForClass:[NSRunLoop class]];
    void (^callbacks)(NSInvocation *) = ^(NSInvocation *invocation) {
        [connection connection:urlConnectionMock didReceiveResponse:[self responseMockWithStatusCode:500]];
        [connection connectionDidFinishLoading:urlConnectionMock];
    };
    [[[runLoopMock stub] andDo:callbacks] runMode:NSDefaultRunLoopMode beforeDate:[OCMArg any]];
    [connection setRunLoop:runLoopMock];

    STAssertThrows([connection retrieveServerStatus], @"Should have raised an exception");
}




@end
