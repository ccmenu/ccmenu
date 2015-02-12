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
    NSURLConnection *dummyNSURLConnection = [self setUpDummyNSURLConnection];

    id delegateMock = OCMProtocolMock(@protocol(CCMConnectionDelegate));
    __block NSArray *recordedInfoList = nil; // workaround until OCMock can better capture args
    void (^record)(NSInvocation *) = ^(NSInvocation *invocation) {
        [invocation getArgument:&recordedInfoList atIndex:3];
    };
    OCMStub([delegateMock connection:connection didReceiveServerStatus:[OCMArg any]]).andDo(record);
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
    NSURLConnection *dummyNSURLConnection = [self setUpDummyNSURLConnection];

    id delegateMock = OCMProtocolMock(@protocol(CCMConnectionDelegate));
    __block NSArray *recordedError = nil;
    void (^record)(NSInvocation *) = ^(NSInvocation *invocation) {
        [invocation getArgument:&recordedError atIndex:3];
    };
    OCMStub([delegateMock connection:connection hadTemporaryError:[OCMArg any]]).andDo(record);
    [connection setDelegate:delegateMock];

    [connection requestServerStatus];
    [connection connection:dummyNSURLConnection didReceiveResponse:[self responseMockWithStatusCode:500]];
    // make sure we don't rely on parse errors to detect error responses
    [connection connection:dummyNSURLConnection didReceiveData:[@"<Projects></Projects>" dataUsingEncoding:NSASCIIStringEncoding]];
    [connection connectionDidFinishLoading:dummyNSURLConnection];

    XCTAssertNotNil(recordedError, @"Should have called delegate with error.");
}

- (void)testRetriesWithUnpromptedBasicAuthAfterResponseWithForbiddenStatusFromJenkinsOrHudson
{
    CCMConnection *connection = [[[CCMConnection alloc] init] autorelease];
    NSURLCredential *credential = [NSURLCredential credentialWithUser:@"bob" password:@"123456" persistence:NSURLCredentialPersistenceForSession];
    [connection setCredential:credential];
    
    __block NSURLRequest *recordedNSURLRequest = nil;
    BOOL (^record)(id) = ^BOOL(id obj) {
        recordedNSURLRequest = obj;
        return YES;
    };
    NSURLConnection *dummyNSURLConnection = [self setUpDummyNSURLConnection:[OCMArg checkWithBlock:record]];

    [connection requestServerStatus];
    XCTAssertEqualObjects([recordedNSURLRequest valueForHTTPHeaderField:@"Authorization"], nil, @"Should not have added an auth header on its own");

    NSHTTPURLResponse *firstResponseMock = [self responseMockWithStatusCode:403];
    OCMStub([firstResponseMock allHeaderFields]).andReturn(@{ @"X-Jenkins": @"1.0" });
    [connection connection:dummyNSURLConnection didReceiveResponse:firstResponseMock];

    recordedNSURLRequest = nil; // reset here, because we expect the didFinishLoading method to start another request
    [connection connectionDidFinishLoading:dummyNSURLConnection];
    XCTAssertNotNil(recordedNSURLRequest, @"Should have retried");
    XCTAssertEqualObjects([recordedNSURLRequest valueForHTTPHeaderField:@"Authorization"], @"Basic Ym9iOjEyMzQ1Ng==", @"Should have added an auth header now");
}


- (void)testLazilyCreatesCredentialWhenNeededForAuthChallenge
{
    CCMConnection *connection = [[[CCMConnection alloc] initWithURLString:@"http://testuser@testhost"] autorelease];
    NSURLConnection *dummyNSURLConnection = [self setUpDummyNSURLConnection];

    id keychainHelperMock = OCMClassMock([CCMKeychainHelper class]);
    [[[keychainHelperMock stub] andReturn:@"testpassword"] passwordForURL:[OCMArg any] error:[OCMArg anyPointer]];

    id challengeMock = OCMClassMock([NSURLAuthenticationChallenge class]);
    id protectionSpaceMock = OCMClassMock([NSURLProtectionSpace class]);
    id senderMock = OCMProtocolMock(@protocol(NSURLAuthenticationChallengeSender));
    OCMStub([protectionSpaceMock authenticationMethod]).andReturn(NSURLAuthenticationMethodHTTPBasic);
    NSURLCredential *credential = [NSURLCredential credentialWithUser:@"testuser" password:@"testpassword" persistence:NSURLCredentialPersistenceForSession];
    OCMStub([challengeMock protectionSpace]).andReturn(protectionSpaceMock);
    OCMStub([challengeMock previousFailureCount]).andReturn(0);
    OCMStub([challengeMock sender]).andReturn(senderMock);

    [connection connection:dummyNSURLConnection willSendRequestForAuthenticationChallenge:challengeMock];

    OCMVerify([senderMock useCredential:credential forAuthenticationChallenge:challengeMock]);
}

- (void)testCancelsAuthChallengeWhenCredentialCannotBeCreated
{
    CCMConnection *connection = [[[CCMConnection alloc] initWithURLString:@"http://testhost"] autorelease];
    NSURLConnection *dummyNSURLConnection = [self setUpDummyNSURLConnection];

    id challengeMock = OCMClassMock([NSURLAuthenticationChallenge class]);
    id protectionSpaceMock = OCMClassMock([NSURLProtectionSpace class]);
    id senderMock = OCMProtocolMock(@protocol(NSURLAuthenticationChallengeSender));
    OCMStub([protectionSpaceMock authenticationMethod]).andReturn(NSURLAuthenticationMethodHTTPBasic);
    OCMStub([challengeMock protectionSpace]).andReturn(protectionSpaceMock);
    OCMStub([challengeMock previousFailureCount]).andReturn(0);
    OCMStub([challengeMock sender]).andReturn(senderMock);

    [connection connection:dummyNSURLConnection willSendRequestForAuthenticationChallenge:challengeMock];

    OCMVerify([senderMock cancelAuthenticationChallenge:challengeMock]);
}

- (void)testCancelsAuthChallengeWhenCredentialIsPresentButFailCountIsNotZero
{
    CCMConnection *connection = [[[CCMConnection alloc] initWithURLString:@"http://testhost"] autorelease];
    NSURLConnection *dummyNSURLConnection = [self setUpDummyNSURLConnection];
    [connection setCredential:[NSURLCredential credentialWithUser:@"testuser" password:@"testpassword" persistence:NSURLCredentialPersistenceForSession]];

    id challengeMock = OCMClassMock([NSURLAuthenticationChallenge class]);
    id protectionSpaceMock = OCMClassMock([NSURLProtectionSpace class]);
    id senderMock = OCMProtocolMock(@protocol(NSURLAuthenticationChallengeSender));
    OCMStub([protectionSpaceMock authenticationMethod]).andReturn(NSURLAuthenticationMethodHTTPBasic);
    OCMStub([challengeMock protectionSpace]).andReturn(protectionSpaceMock);
    OCMStub([challengeMock previousFailureCount]).andReturn(1);
    OCMStub([challengeMock sender]).andReturn(senderMock);

    [connection connection:dummyNSURLConnection willSendRequestForAuthenticationChallenge:challengeMock];

    OCMVerify([senderMock cancelAuthenticationChallenge:challengeMock]);
}


- (void)testSetsCredentialInResponseToServerTrustChallengeWhenCertIsTrusted
{
    CCMConnection *connection = [[[CCMConnection alloc] initWithURLString:@"http://testhost"] autorelease];
    NSURLConnection *dummyNSURLConnection = [self setUpDummyNSURLConnection];

    const SecTrustRef dummyServerTrust = (void *)0x1234567;

    id challengeMock = OCMClassMock([NSURLAuthenticationChallenge class]);
    id protectionSpaceMock = OCMClassMock([NSURLProtectionSpace class]);
    id senderMock = OCMProtocolMock(@protocol(NSURLAuthenticationChallengeSender));
    OCMStub([protectionSpaceMock authenticationMethod]).andReturn(NSURLAuthenticationMethodServerTrust);
    OCMStub([protectionSpaceMock serverTrust]).andReturn(dummyServerTrust);
    OCMStub([challengeMock protectionSpace]).andReturn(protectionSpaceMock);
    OCMStub([challengeMock sender]).andReturn(senderMock);

    id partialMock = OCMPartialMock(connection);
    OCMStub([partialMock shouldContinueWithServerTrust:dummyServerTrust]).andReturn(YES);

    [connection connection:dummyNSURLConnection willSendRequestForAuthenticationChallenge:challengeMock];

    OCMVerify([senderMock useCredential:[OCMArg isNotNil] forAuthenticationChallenge:challengeMock]);
}


- (void)testRejectsServerTrustChallengeWhenCertNotTrusted
{
    CCMConnection *connection = [[[CCMConnection alloc] initWithURLString:@"http://testhost"] autorelease];
    NSURLConnection *dummyNSURLConnection = [self setUpDummyNSURLConnection];

    const SecTrustRef dummyServerTrust = (void *)0x1234567;

    id challengeMock = OCMClassMock([NSURLAuthenticationChallenge class]);
    id protectionSpaceMock = OCMClassMock([NSURLProtectionSpace class]);
    id senderMock = OCMProtocolMock(@protocol(NSURLAuthenticationChallengeSender));
    OCMStub([protectionSpaceMock authenticationMethod]).andReturn(NSURLAuthenticationMethodServerTrust);
    OCMStub([protectionSpaceMock serverTrust]).andReturn(dummyServerTrust);
    OCMStub([challengeMock protectionSpace]).andReturn(protectionSpaceMock);
    OCMStub([challengeMock sender]).andReturn(senderMock);

    id partialMock = OCMPartialMock(connection);
    OCMStub([partialMock shouldContinueWithServerTrust:dummyServerTrust]).andReturn(NO);

    [connection connection:dummyNSURLConnection willSendRequestForAuthenticationChallenge:challengeMock];

    OCMVerify([senderMock rejectProtectionSpaceAndContinueWithChallenge:challengeMock]);
}

@end
