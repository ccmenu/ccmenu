
#import <OCMock/OCMock.h>
#import "CCMConnectionTestBase.h"


@implementation CCMConnectionTestBase

- (void)setUpDummyNSURLConnection
{
    dummyNSURLConnection = [NSURLConnection connectionWithRequest:nil delegate:nil];
    id mockForClassMethod = OCMClassMock([NSURLConnection class]);
    OCMStub([mockForClassMethod connectionWithRequest:[OCMArg any] delegate:[OCMArg any]]).andReturn(dummyNSURLConnection);
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