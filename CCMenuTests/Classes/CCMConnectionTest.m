#import <OCMock/OCMock.h>
#import "CCMConnection.h"
#import "CCMKeychainHelper.h"
#import "CCMConnectionTestBase.h"


@interface CCMConnectionTest : CCMConnectionTestBase

@end


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

    XCTAssertEqualObjects([[recordedInfoList objectAtIndex:0] valueForKey:@"name"], @"connectfour", @"Should have called delegate with info object corresponding to response");
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

    XCTAssertNotNil(recordedError, @"Should have called delegate with error.");
}

- (void)testLazilyCreatesCredentialWhenNeededForAuthChallenge
{
    CCMConnection *connection = [[[CCMConnection alloc] initWithURLString:@"http://testuser@testhost"] autorelease];
    [self setUpDummyNSURLConnection];

    id keychainHelperMock = [OCMockObject mockForClass:[CCMKeychainHelper class]];
    [[[keychainHelperMock stub] andReturn:@"testpassword"] passwordForURL:[OCMArg any] error:[OCMArg anyPointer]];

    id challengeMock = [OCMockObject mockForClass:[NSURLAuthenticationChallenge class]];
    id protectionSpaceMock = [OCMockObject mockForClass:[NSURLProtectionSpace class]];
    id senderMock = [OCMockObject mockForProtocol:@protocol(NSURLAuthenticationChallengeSender)];
    [[[protectionSpaceMock stub] andReturn:NSURLAuthenticationMethodHTTPBasic] authenticationMethod];
    NSURLCredential *credential = [NSURLCredential credentialWithUser:@"testuser" password:@"testpassword" persistence:NSURLCredentialPersistenceForSession];
    [[[challengeMock stub] andReturn:protectionSpaceMock] protectionSpace];
    [[[challengeMock stub] andReturnValue:OCMOCK_VALUE((NSInteger){0})] previousFailureCount];
    [[[challengeMock stub] andReturn:senderMock] sender];
    [[senderMock expect] useCredential:credential forAuthenticationChallenge:challengeMock];

    [connection connection:dummyNSURLConnection willSendRequestForAuthenticationChallenge:challengeMock];

    [senderMock verify];
}

- (void)testCancelsAuthChallengeWhenCredentialCannotBeCreated
{
    CCMConnection *connection = [[[CCMConnection alloc] initWithURLString:@"http://testhost"] autorelease];
    [self setUpDummyNSURLConnection];

    id challengeMock = [OCMockObject mockForClass:[NSURLAuthenticationChallenge class]];
    id protectionSpaceMock = [OCMockObject mockForClass:[NSURLProtectionSpace class]];
    id senderMock = [OCMockObject mockForProtocol:@protocol(NSURLAuthenticationChallengeSender)];
    [[[protectionSpaceMock stub] andReturn:NSURLAuthenticationMethodHTTPBasic] authenticationMethod];
    [[[challengeMock stub] andReturn:protectionSpaceMock] protectionSpace];
    [[[challengeMock stub] andReturnValue:OCMOCK_VALUE((NSInteger){0})] previousFailureCount];
    [[[challengeMock stub] andReturn:senderMock] sender];
    [[senderMock expect] cancelAuthenticationChallenge:challengeMock];

    [connection connection:dummyNSURLConnection willSendRequestForAuthenticationChallenge:challengeMock];

    [senderMock verify];
}

- (void)testCancelsAuthChallengeWhenCredentialIsPresentButFailCountIsNotZero
{
    CCMConnection *connection = [[[CCMConnection alloc] initWithURLString:@"http://testhost"] autorelease];
    [self setUpDummyNSURLConnection];
    [connection setCredential:[NSURLCredential credentialWithUser:@"testuser" password:@"testpassword" persistence:NSURLCredentialPersistenceForSession]];

    id challengeMock = [OCMockObject mockForClass:[NSURLAuthenticationChallenge class]];
    id protectionSpaceMock = [OCMockObject mockForClass:[NSURLProtectionSpace class]];
    id senderMock = [OCMockObject mockForProtocol:@protocol(NSURLAuthenticationChallengeSender)];
    [[[protectionSpaceMock stub] andReturn:NSURLAuthenticationMethodHTTPBasic] authenticationMethod];
    [[[challengeMock stub] andReturn:protectionSpaceMock] protectionSpace];
    [[[challengeMock stub] andReturnValue:OCMOCK_VALUE((NSInteger){1})] previousFailureCount];
    [[[challengeMock stub] andReturn:senderMock] sender];
    [[senderMock expect] cancelAuthenticationChallenge:challengeMock];

    [connection connection:dummyNSURLConnection willSendRequestForAuthenticationChallenge:challengeMock];

    [senderMock verify];
}


- (void)testSetsCredentialInResponseToServerTrustChallengeWhenCertIsTrusted
{
    CCMConnection *connection = [[[CCMConnection alloc] initWithURLString:@"http://testhost"] autorelease];
    [self setUpDummyNSURLConnection];

    const SecTrustRef dummyServerTrust = (void *)0x1234567;

    id challengeMock = [OCMockObject mockForClass:[NSURLAuthenticationChallenge class]];
    id protectionSpaceMock = [OCMockObject mockForClass:[NSURLProtectionSpace class]];
    id senderMock = [OCMockObject mockForProtocol:@protocol(NSURLAuthenticationChallengeSender)];
    [[[protectionSpaceMock stub] andReturn:NSURLAuthenticationMethodServerTrust] authenticationMethod];
    [[[protectionSpaceMock stub] andReturnValue:OCMOCK_VALUE(dummyServerTrust)] serverTrust];
    [[[challengeMock stub] andReturn:protectionSpaceMock] protectionSpace];
    [[[challengeMock stub] andReturn:senderMock] sender];
    [[senderMock expect] useCredential:[OCMArg isNotNil] forAuthenticationChallenge:challengeMock];

    id partialMock = [OCMockObject partialMockForObject:connection];
    [[[partialMock stub] andReturnValue:OCMOCK_VALUE((BOOL){YES})] shouldContinueWithServerTrust:dummyServerTrust];

    [connection connection:dummyNSURLConnection willSendRequestForAuthenticationChallenge:challengeMock];

    [senderMock verify];
}


- (void)testRejectsServerTrustChallengeWhenCertNotTrusted
{
    CCMConnection *connection = [[[CCMConnection alloc] initWithURLString:@"http://testhost"] autorelease];
    [self setUpDummyNSURLConnection];

    const SecTrustRef dummyServerTrust = (void *)0x1234567;

    id challengeMock = [OCMockObject mockForClass:[NSURLAuthenticationChallenge class]];
    id protectionSpaceMock = [OCMockObject mockForClass:[NSURLProtectionSpace class]];
    id senderMock = [OCMockObject mockForProtocol:@protocol(NSURLAuthenticationChallengeSender)];
    [[[protectionSpaceMock stub] andReturn:NSURLAuthenticationMethodServerTrust] authenticationMethod];
    [[[protectionSpaceMock stub] andReturnValue:OCMOCK_VALUE(dummyServerTrust)] serverTrust];
    [[[challengeMock stub] andReturn:protectionSpaceMock] protectionSpace];
    [[[challengeMock stub] andReturn:senderMock] sender];
    [[senderMock expect] rejectProtectionSpaceAndContinueWithChallenge:challengeMock];

    id partialMock = [OCMockObject partialMockForObject:connection];
    [[[partialMock stub] andReturnValue:OCMOCK_VALUE((BOOL){NO})] shouldContinueWithServerTrust:dummyServerTrust];

    [connection connection:dummyNSURLConnection willSendRequestForAuthenticationChallenge:challengeMock];

    [senderMock verify];
}

@end
