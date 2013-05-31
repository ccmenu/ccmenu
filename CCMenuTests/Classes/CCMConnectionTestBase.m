
#import <OCMock/OCMock.h>
#import "CCMConnectionTestBase.h"


@implementation CCMConnectionTestBase

- (void)setUpDummyNSURLConnection
{
    dummyNSURLConnection = [NSURLConnection connectionWithRequest:nil delegate:nil];
    id mockForClassMethod = [OCMockObject mockForClass:[NSURLConnection class]];
    [[[mockForClassMethod stub] andReturn:dummyNSURLConnection] connectionWithRequest:[OCMArg any] delegate:[OCMArg any]];
}

- (NSData *)responseData
{
    NSString *text = @"<Projects><Project name='connectfour' activity='Sleeping' lastBuildStatus='Success' lastBuildLabel='build.1' lastBuildTime='2007-07-18T18:44:48' webUrl='http://localhost:8080/dashboard/build/detail/connectfour'/></Projects>";
    return [text dataUsingEncoding:NSASCIIStringEncoding];
}

- (id)responseMockWithStatusCode:(NSInteger)statusCode
{
    id responseMock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(statusCode)] statusCode];
    return responseMock;
}

@end