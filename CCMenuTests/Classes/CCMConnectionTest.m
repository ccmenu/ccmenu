#import <OCMock/OCMock.h>
#import "CCMConnection.h"
#import "CCMConnectionTest.h"


@implementation CCMConnectionTest

- (void)testRetrievesStatusAsynchronously
{
    CCMConnection *connection = [[[CCMConnection alloc] init] autorelease];
    [self setUpDummyNSURLConnection];

    id delegateMock = [OCMockObject mockForProtocol:@protocol(CCMConnectionDelegate)];
    __block NSArray *recordedInfoList = nil; // workaround until OCMock can better capture args
    void (^record)(NSInvocation *) = ^(NSInvocation *invocation) {
        [invocation getArgument:&recordedInfoList atIndex:3];
    };
    [[[delegateMock expect] andDo:record] connection:connection didReceiveServerStatus:[OCMArg any]];
    [connection setDelegate:delegateMock];

    [connection requestServerStatus];
    [connection connection:dummyNSURLConnection didReceiveResponse:[self responseMockWithStatusCode:200]];
    [connection connection:dummyNSURLConnection didReceiveData:[self responseData]];
    [connection connectionDidFinishLoading:dummyNSURLConnection];

    STAssertEqualObjects([[recordedInfoList objectAtIndex:0] valueForKey:@"name"], @"connectfour", @"Should have called delegate with info object corresponding to response");
}

- (void)testReportsErrorWhenAsychronousRetrievalOfStatusFailed
{
    CCMConnection *connection = [[[CCMConnection alloc] init] autorelease];
    [self setUpDummyNSURLConnection];

    id delegateMock = [OCMockObject mockForProtocol:@protocol(CCMConnectionDelegate)];
    __block NSArray *recordedError = nil;
    void (^record)(NSInvocation *) = ^(NSInvocation *invocation) {
        [invocation getArgument:&recordedError atIndex:3];
    };
    [[[delegateMock expect] andDo:record] connection:connection hadTemporaryError:[OCMArg any]];
    [connection setDelegate:delegateMock];

    [connection requestServerStatus];
    [connection connection:dummyNSURLConnection didReceiveResponse:[self responseMockWithStatusCode:500]];
    [connection connectionDidFinishLoading:dummyNSURLConnection];

    STAssertNotNil(recordedError, @"connectfour", @"Should have called delegate with error.");
}

- (void)testOnFirstAttemptUsesProposedCredentialWithoutAskingDelegate
{
    CCMConnection *connection = [[[CCMConnection alloc] init] autorelease];
    [self setUpDummyNSURLConnection];

    id delegateMock = [OCMockObject mockForProtocol:@protocol(CCMConnectionDelegate)];
    [connection setDelegate:delegateMock];

    id challengeMock = [OCMockObject mockForClass:[NSURLAuthenticationChallenge class]];
    [[[challengeMock stub] andReturnValue:OCMOCK_VALUE((NSInteger){0})] previousFailureCount];

    NSURLCredential *credential = [NSURLCredential credentialWithUser:@"dummy" password:@"testpassword" persistence:NSURLCredentialPersistenceNone];
    [[[challengeMock stub] andReturn:credential] proposedCredential];

    id senderMock = [OCMockObject mockForProtocol:@protocol(NSURLAuthenticationChallengeSender)];
    [[senderMock expect] useCredential:credential forAuthenticationChallenge:challengeMock];
    [[[challengeMock stub] andReturn:senderMock] sender];

    [connection connection:dummyNSURLConnection willSendRequestForAuthenticationChallenge:challengeMock];

    // if the connection calls its delegate method the mock will complain because its unexpected
    [senderMock verify];
}


@end
