
#import <OCMock/OCMock.h>
#import "CCMSyncConnection.h"
#import "CCMConnectionTestBase.h"


@interface CCMSyncConnectionTest : CCMConnectionTestBase

@end


@implementation CCMSyncConnectionTest

- (void)testConnectionTestReturnsServerStatusCode
{
    CCMSyncConnection *connection = [[[CCMSyncConnection alloc] initWithURLString:@"http://dummy"] autorelease];
    NSURLConnection *dummyNSURLConnection = [self setUpDummyNSURLConnection];

    id runLoopMock = OCMClassMock([NSRunLoop class]);
    void (^callbacks)(NSInvocation *) = ^(NSInvocation *invocation) {
        [connection connection:dummyNSURLConnection didReceiveResponse:[self responseMockWithStatusCode:200]];
        [connection connectionDidFinishLoading:dummyNSURLConnection];
    };
    OCMStub([runLoopMock runMode:NSDefaultRunLoopMode beforeDate:[OCMArg any]]).andDo(callbacks);
    [connection setRunLoop:runLoopMock];

    NSInteger statusCode = [connection testConnection];
    
    XCTAssertEqual((NSInteger)200, statusCode, @"Should have indicated success.");
}

@end
