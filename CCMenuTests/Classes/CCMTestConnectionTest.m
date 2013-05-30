
#import <OCMock/OCMock.h>
#import "CCMTestConnection.h"
#import "CCMTestConnectionTest.h"


@implementation CCMTestConnectionTest

- (void)testConnectionTestSuccessfulWhenServerReturns200StatusCode
{
    CCMTestConnection *connection = [[[CCMTestConnection alloc] initWithURLString:@"http://dummy"] autorelease];
    
    id urlConnectionMock = [OCMockObject mockForClass:[NSURLConnection class]];
    [[[urlConnectionMock stub] andReturn:urlConnectionMock] connectionWithRequest:[OCMArg any] delegate:connection];

    id runLoopMock = [OCMockObject mockForClass:[NSRunLoop class]];
    void (^callbacks)(NSInvocation *) = ^(NSInvocation *invocation) {
        id responseMock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
        [[[responseMock stub] andReturnValue:OCMOCK_VALUE((NSInteger){200})] statusCode];
        [connection connection:urlConnectionMock didReceiveResponse:responseMock];
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
        id responseMock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
        [[[responseMock stub] andReturnValue:OCMOCK_VALUE((NSInteger){404})] statusCode];
        [connection connection:urlConnectionMock didReceiveResponse:responseMock];
        [connection connectionDidFinishLoading:urlConnectionMock];
    };
    [[[runLoopMock stub] andDo:callbacks] runMode:NSDefaultRunLoopMode beforeDate:[OCMArg any]];
    [connection setRunLoop:runLoopMock];

    BOOL success = [connection testConnection];
    
    STAssertFalse(success, @"Should have indicated failure.");
}


@end
