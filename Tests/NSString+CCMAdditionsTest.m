
#import "NSString+CCMAdditionsTest.h"
#import "NSString+CCMAdditions.h"


@implementation NSString_CCMAddtionsTest

- (void)testDetectsCruiseControlDashboardURLs
{
	CCMServerType type = [@"http://localhost/cctray.xml" cruiseControlServerType];
	STAssertEquals(CCMCruiseControlDashboard, type, @"Should have detected dashboard URL.");
}

- (void)testDetectsClassicCruiseControlURLs
{
	CCMServerType type = [@"http://localhost/xml" cruiseControlServerType];
	STAssertEquals(CCMCruiseControlClassic, type, @"Should have detected classic reporting app URL.");
}

- (void)testDetectsCruiseControlDotNetURLs
{
	CCMServerType type = [@"http://localhost/XmlStatusReport.aspx" cruiseControlServerType];
	STAssertEquals(CCMCruiseControlDotNetServer, type, @"Should have detected CC.NET URL.");
}

- (void)testTreatsRandomXMLFileExtensionAsUnknown
{
	CCMServerType type = [@"http://localhost/foo.xml" cruiseControlServerType];
	STAssertEquals(CCMUnknownServer, type, @"Should have detected classic reporting app URL.");
}

- (void)testCompletesCruiseControlDashboardURL
{
	NSString *url = [@"http://localhost/" completeCruiseControlURLForServerType:CCMCruiseControlDashboard];
	STAssertEqualObjects(@"http://localhost/cctray.xml", url, @"Should have completed URL.");
}

- (void)testAddsMissingTrailingSlashWhenCompletingURLs
{
	NSString *url = [@"http://localhost" completeCruiseControlURLForServerType:CCMCruiseControlDashboard];
	STAssertEqualObjects(@"http://localhost/cctray.xml", url, @"Should have completed URL.");
}

- (void)testDoesNotAddFilenameWhenCorrectFilenameIsPresentWhenCompletingURLs
{
	NSString *url = [@"http://localhost/cctray.xml" completeCruiseControlURLForServerType:CCMCruiseControlDashboard];
	STAssertEqualObjects(@"http://localhost/cctray.xml", url, @"Should have completed URL.");
}

- (void)testAddsHTTPSchemeWhenCompletingURLs
{
	NSString *url = [@"localhost/cctray.xml" completeCruiseControlURLForServerType:CCMCruiseControlDashboard];
	STAssertEqualObjects(@"http://localhost/cctray.xml", url, @"Should have completed URL.");
}

- (void)testLeavesHTTPSSchemeWhenCompletingURLs
{
	NSString *url = [@"https://localhost/cctray.xml" completeCruiseControlURLForServerType:CCMCruiseControlDashboard];
	STAssertEqualObjects(@"https://localhost/cctray.xml", url, @"Should have kept HTTPS scheme.");
}

- (void)testCompletesCruiseControlClassicURLs
{
	NSString *url = [@"localhost" completeCruiseControlURLForServerType:CCMCruiseControlClassic];
	STAssertEqualObjects(@"http://localhost/xml", url, @"Should have completed URL.");
}

- (void)testCompletesCruiseControlDotNetURLs
{
	NSString *url = [@"localhost" completeCruiseControlURLForServerType:CCMCruiseControlDotNetServer];
	STAssertEqualObjects(@"http://localhost/XmlStatusReport.aspx", url, @"Should have completed URL.");
}

- (void)testCompletesCruiseControlURLs
{
	NSArray *urls = [@"http://localhost" completeCruiseControlURLs];
	STAssertTrue([urls containsObject:@"http://localhost/cctray.xml"], @"Should have returned dashboard URL.");
	STAssertTrue([urls containsObject:@"http://localhost/dashboard/cctray.xml"], @"Should have returned alternate dashboard URL.");
	STAssertTrue([urls containsObject:@"http://localhost/xml"], @"Should have returned classic reporting URL.");
	STAssertTrue([urls containsObject:@"http://localhost/XmlStatusReport.aspx"], @"Should have returned CC.NET URL.");
	STAssertTrue([urls containsObject:@"http://localhost/ccnet/XmlStatusReport.aspx"], @"Should have returned alternate CC.NET URL.");
	STAssertEquals(5u, [urls count], @"Should have returned only expected urls.");
}

- (void)testOnlyReturnsOneCompleteURLWhenURLWasComplete
{
	NSArray *urls = [@"localhost/XmlStatusReport.aspx" completeCruiseControlURLs];
	STAssertTrue([urls containsObject:@"http://localhost/XmlStatusReport.aspx"], @"Should have returned complete URL.");
	STAssertEquals(1u, [urls count], @"Should have returned only one urls.");
}

- (void)testRemovesDashboardFileNameIfPresent
{
	NSString *url = [@"http://localhost/cctray.xml" stringByRemovingCruiseControlReportFileName];
	STAssertEqualObjects(@"http://localhost/", url, @"Should have removed filename part from URL.");
}


@end
