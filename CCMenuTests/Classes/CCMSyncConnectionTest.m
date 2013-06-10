
#import <OCMock/OCMock.h>
#import "CCMSyncConnection.h"
#import "CCMSyncConnectionTest.h"


@implementation CCMSyncConnectionTest

- (void)testConnectionTestReturnsServerStatusCode
{
    CCMSyncConnection *connection = [[[CCMSyncConnection alloc] initWithURLString:@"http://dummy"] autorelease];
    [self setUpDummyNSURLConnection];

    id runLoopMock = [OCMockObject mockForClass:[NSRunLoop class]];
    void (^callbacks)(NSInvocation *) = ^(NSInvocation *invocation) {
        [connection connection:dummyNSURLConnection didReceiveResponse:[self responseMockWithStatusCode:200]];
        [connection connectionDidFinishLoading:dummyNSURLConnection];
    };
    [[[runLoopMock stub] andDo:callbacks] runMode:NSDefaultRunLoopMode beforeDate:[OCMArg any]];
    [connection setRunLoop:runLoopMock];

    NSInteger statusCode = [connection testConnection];
    
    STAssertEquals((NSInteger)200, statusCode, @"Should have indicated success.");
}

- (void)testRetrievesStatusSynchronously
{
    CCMSyncConnection *connection = [[[CCMSyncConnection alloc] initWithURLString:@"http://dummy"] autorelease];
    [self setUpDummyNSURLConnection];

    id runLoopMock = [OCMockObject mockForClass:[NSRunLoop class]];
    void (^callbacks)(NSInvocation *) = ^(NSInvocation *invocation) {
        [connection connection:dummyNSURLConnection didReceiveResponse:[self responseMockWithStatusCode:200]];
        [connection connection:dummyNSURLConnection didReceiveData:[self responseData]];
        [connection connectionDidFinishLoading:dummyNSURLConnection];
    };
    [[[runLoopMock stub] andDo:callbacks] runMode:NSDefaultRunLoopMode beforeDate:[OCMArg any]];
    [connection setRunLoop:runLoopMock];

    NSArray *infos = [connection retrieveServerStatus];

    STAssertEqualObjects([[infos objectAtIndex:0] valueForKey:@"name"], @"connectfour", @"Should have returned info object corresponding to response");
}

- (void)testRaisesExceptionWhenRetrievingStatusAndResponseStatusCodeIsNot200OK
{
    CCMSyncConnection *connection = [[[CCMSyncConnection alloc] initWithURLString:@"http://dummy"] autorelease];
    [self setUpDummyNSURLConnection];

    id runLoopMock = [OCMockObject mockForClass:[NSRunLoop class]];
    void (^callbacks)(NSInvocation *) = ^(NSInvocation *invocation) {
        [connection connection:dummyNSURLConnection didReceiveResponse:[self responseMockWithStatusCode:500]];
        [connection connectionDidFinishLoading:dummyNSURLConnection];
    };
    [[[runLoopMock stub] andDo:callbacks] runMode:NSDefaultRunLoopMode beforeDate:[OCMArg any]];
    [connection setRunLoop:runLoopMock];

    STAssertThrows([connection retrieveServerStatus], @"Should have raised an exception");
}

- (void)testRaisesExceptionWhenRetrievingStatusAndUnderlyingConnectionFailedWithError
{
    CCMSyncConnection *connection = [[[CCMSyncConnection alloc] initWithURLString:@"http://dummy"] autorelease];
    [self setUpDummyNSURLConnection];

    id runLoopMock = [OCMockObject mockForClass:[NSRunLoop class]];
    void (^callbacks)(NSInvocation *) = ^(NSInvocation *invocation) {
        NSError *dummyError = [NSError errorWithDomain:@"test" code:0 userInfo:nil];
        [connection connection:dummyNSURLConnection didFailWithError:dummyError];
    };
    [[[runLoopMock stub] andDo:callbacks] runMode:NSDefaultRunLoopMode beforeDate:[OCMArg any]];
    [connection setRunLoop:runLoopMock];

    STAssertThrows([connection retrieveServerStatus], @"Should have raised an exception");
}


@end
