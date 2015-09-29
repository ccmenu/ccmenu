
#import <OCMock/OCMock.h>
#import "CCMConnectionTestBase.h"


@implementation CCMConnectionTestBase

- (NSURLConnection *)setUpDummyNSURLConnection
{
    return [self setUpDummyNSURLConnection:[OCMArg any]];
}

- (NSURLConnection *)setUpDummyNSURLConnection:(id)requestArgConstraint
{
    NSURLRequest *dummyRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"file://tmp/dummy"]];
    NSURLConnection *dummyNSURLConnection = [NSURLConnection connectionWithRequest:dummyRequest delegate:nil];
    id mockForClassMethod = OCMClassMock([NSURLConnection class]);
    OCMStub([mockForClassMethod connectionWithRequest:requestArgConstraint delegate:[OCMArg any]]).andReturn(dummyNSURLConnection);
    return dummyNSURLConnection;
}


- (NSData *)responseData
{
    NSString *text = @"<Projects><Project name='connectfour' activity='Sleeping' lastBuildStatus='Success' lastBuildLabel='build.1' lastBuildTime='2007-07-18T18:44:48' webUrl='http://localhost:8080/dashboard/build/detail/connectfour'/></Projects>";
    return [text dataUsingEncoding:NSASCIIStringEncoding];
}

- (id)responseMockWithStatusCode:(NSInteger)statusCode
{
    id responseMock = OCMClassMock([NSHTTPURLResponse class]);
    OCMStub([responseMock statusCode]).andReturn(statusCode);
    return responseMock;
}

@end