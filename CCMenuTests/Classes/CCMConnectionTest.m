#import <OCMock/OCMock.h>
#import "CCMConnection.h"
#import "CCMConnectionTest.h"
#import "CCMKeychainHelper.h"


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

- (void)testLazilyCreatesCredentialWhenNeededForAuthChallenge
{
    CCMConnection *connection = [[[CCMConnection alloc] initWithURLString:@"http://testuser@testhost"] autorelease];
    [self setUpDummyNSURLConnection];

    id keychainHelperMock = [OCMockObject mockForClass:[CCMKeychainHelper class]];
    [[[keychainHelperMock stub] andReturn:@"testpassword"] passwordForURL:[OCMArg any] error:[OCMArg anyPointer]];

    id challengeMock = [OCMockObject mockForClass:[NSURLAuthenticationChallenge class]];
    [[[challengeMock stub] andReturnValue:OCMOCK_VALUE((NSInteger){0})] previousFailureCount];
    id senderMock = [OCMockObject mockForProtocol:@protocol(NSURLAuthenticationChallengeSender)];
    [[[challengeMock stub] andReturn:senderMock] sender];
    NSURLCredential *credential = [NSURLCredential credentialWithUser:@"testuser" password:@"testpassword" persistence:NSURLCredentialPersistenceForSession];
    [[senderMock expect] useCredential:credential forAuthenticationChallenge:challengeMock];

    [connection connection:dummyNSURLConnection didReceiveAuthenticationChallenge:challengeMock];

    [senderMock verify];
}

- (void)testCancelsAuthChallengeWhenCredentialCannotBeCreated
{
    CCMConnection *connection = [[[CCMConnection alloc] initWithURLString:@"http://testhost"] autorelease];
    [self setUpDummyNSURLConnection];

    id challengeMock = [OCMockObject mockForClass:[NSURLAuthenticationChallenge class]];
    [[[challengeMock stub] andReturnValue:OCMOCK_VALUE((NSInteger){0})] previousFailureCount];
    id senderMock = [OCMockObject mockForProtocol:@protocol(NSURLAuthenticationChallengeSender)];
    [[[challengeMock stub] andReturn:senderMock] sender];
    [[senderMock expect] cancelAuthenticationChallenge:challengeMock];

    [connection connection:dummyNSURLConnection didReceiveAuthenticationChallenge:challengeMock];

    [senderMock verify];
}

- (void)testCancelsAuthChallengeWhenCredentialIsPresentButFailCountIsNotZero
{
    CCMConnection *connection = [[[CCMConnection alloc] initWithURLString:@"http://testhost"] autorelease];
    [self setUpDummyNSURLConnection];
    [connection setCredential:[NSURLCredential credentialWithUser:@"testuser" password:@"testpassword" persistence:NSURLCredentialPersistenceForSession]];

    id challengeMock = [OCMockObject mockForClass:[NSURLAuthenticationChallenge class]];
    [[[challengeMock stub] andReturnValue:OCMOCK_VALUE((NSInteger){1})] previousFailureCount];
    id senderMock = [OCMockObject mockForProtocol:@protocol(NSURLAuthenticationChallengeSender)];
    [[[challengeMock stub] andReturn:senderMock] sender];
    [[senderMock expect] cancelAuthenticationChallenge:challengeMock];

    [connection connection:dummyNSURLConnection didReceiveAuthenticationChallenge:challengeMock];

    [senderMock verify];
}
@end
