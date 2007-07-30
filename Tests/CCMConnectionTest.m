
#import "CCMConnectionTest.h"


@implementation CCMConnectionTest

- (void)testCanGetProjectStatusFromLiveInstallation
{
	NSURL *url = [NSURL fileURLWithPath:@"Tests/cctray.xml"];
    CCMConnection *connection = [[[CCMConnection alloc] initWithURL:url] retain];
    NSArray *response = [connection getProjectInfos];
    
    STAssertNotNil(response, @"Should receive a response.");
    STAssertEquals(7u, [response count], @"Response should be an array.");
}

- (void)testThrowsExceptionWhenStatusUnavailable
{
	NSURL *url = [NSURL URLWithString:@"XXX"];
    CCMConnection *connection = [[[CCMConnection alloc] initWithURL:url] retain];
	STAssertThrows([connection getProjectInfos], @"Should have thrown an exception.");
	
}


@end
