
#import "CCMConnectionTest.h"


@implementation CCMConnectionTest

- (void)testReturnsProjectInfosFromXml
{
	NSURL *url = [NSURL fileURLWithPath:@"Tests/cctray.xml"];
    CCMConnection *connection = [[[CCMConnection alloc] initWithURL:url] retain];
    NSArray *response = [connection getProjectInfos];
    
    STAssertNotNil(response, @"Should receive a response.");
    STAssertEquals(1u, [response count], @"Response should be an array.");
	
	NSDictionary *info = [response objectAtIndex:0];
	STAssertEqualObjects(@"connectfour", [info valueForKey:@"name"], @"Should have copied project name.");
	STAssertEqualObjects(@"Sleeping", [info valueForKey:@"activity"], @"Should have copied activity.");
	STAssertEqualObjects(@"Success", [info valueForKey:@"lastBuildStatus"], @"Should have copied status.");
	STAssertEqualObjects(@"build.1", [info valueForKey:@"lastBuildLabel"], @"Should have copied label.");
	NSTimeZone *timezone = [NSTimeZone defaultTimeZone];
	NSCalendarDate *date = [NSCalendarDate dateWithYear:2007 month:7 day:18 hour:18 minute:44 second:48 timeZone:timezone];
	STAssertTrue([[info valueForKey:@"lastBuildTime"] isKindOfClass:[NSCalendarDate class]], @"Should have returned a date object.");
	STAssertEqualObjects(date, [info valueForKey:@"lastBuildTime"], @"Should have set right last build time.");
	STAssertEqualObjects(@"http://localhost:8080/dashboard/build/detail/connectfour", [info valueForKey:@"webUrl"], @"Should have copied web url.");
}
	
- (void)testThrowsExceptionWhenStatusUnavailable
{
	NSURL *url = [NSURL URLWithString:@"XXX"];
    CCMConnection *connection = [[[CCMConnection alloc] initWithURL:url] retain];
	STAssertThrows([connection getProjectInfos], @"Should have thrown an exception.");
}


@end
