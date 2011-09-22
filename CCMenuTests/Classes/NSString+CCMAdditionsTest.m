
#import "NSString+CCMAdditionsTest.h"
#import "NSString+CCMAdditions.h"


@implementation NSString_CCMAddtionsTest

- (void)testDetectsCruiseControlDashboardURLs
{
	CCMServerType type = [@"http://localhost/cctray.xml" serverType];
	STAssertEquals(CCMCruiseControlDashboard, type, @"Should have detected dashboard URL.");
}

- (void)testDetectsClassicCruiseControlURLs
{
	CCMServerType type = [@"http://localhost/xml" serverType];
	STAssertEquals(CCMCruiseControlClassic, type, @"Should have detected classic reporting app URL.");
}

- (void)testDetectsCruiseControlDotNetURLs
{
	CCMServerType type = [@"http://localhost/XmlStatusReport.aspx" serverType];
	STAssertEquals(CCMCruiseControlDotNetServer, type, @"Should have detected CC.NET URL.");
}

- (void)testDetectsHudsonURLs
{
	CCMServerType type = [@"http://localhost/cc.xml" serverType];
	STAssertEquals(CCMHudsonServer, type, @"Should have detected Hudson URL.");

}

- (void)testTreatsRandomXMLFileExtensionAsUnknown
{
	CCMServerType type = [@"http://localhost/foo.xml" serverType];
	STAssertEquals(CCMUnknownServer, type, @"Should have reported unknown server.");
}

- (void)testCompletesCruiseControlDashboardURL
{
	NSString *url = [@"http://localhost/" completeURLForServerType:CCMCruiseControlDashboard];
	STAssertEqualObjects(@"http://localhost/cctray.xml", url, @"Should have completed URL.");
}

- (void)testAddsMissingTrailingSlashWhenCompletingURLs
{
	NSString *url = [@"http://localhost" completeURLForServerType:CCMCruiseControlDashboard];
	STAssertEqualObjects(@"http://localhost/cctray.xml", url, @"Should have completed URL.");
}

- (void)testDoesNotAddFilenameWhenCorrectFilenameIsPresentWhenCompletingURLs
{
	NSString *url = [@"http://localhost/cctray.xml" completeURLForServerType:CCMCruiseControlDashboard];
	STAssertEqualObjects(@"http://localhost/cctray.xml", url, @"Should have completed URL.");
}

- (void)testAddsHTTPSchemeWhenCompletingURLs
{
	NSString *url = [@"localhost/cctray.xml" completeURLForServerType:CCMCruiseControlDashboard];
	STAssertEqualObjects(@"http://localhost/cctray.xml", url, @"Should have completed URL.");
}

- (void)testLeavesHTTPSSchemeWhenCompletingURLs
{
	NSString *url = [@"https://localhost/cctray.xml" completeURLForServerType:CCMCruiseControlDashboard];
	STAssertEqualObjects(@"https://localhost/cctray.xml", url, @"Should have kept HTTPS scheme.");
}

- (void)testCompletesCruiseControlClassicURLs
{
	NSString *url = [@"localhost" completeURLForServerType:CCMCruiseControlClassic];
	STAssertEqualObjects(@"http://localhost/xml", url, @"Should have completed URL.");
}

- (void)testCompletesCruiseControlDotNetURLs
{
	NSString *url = [@"localhost" completeURLForServerType:CCMCruiseControlDotNetServer];
	STAssertEqualObjects(@"http://localhost/XmlStatusReport.aspx", url, @"Should have completed URL.");
}

- (void)testCompletesHudsonURLs
{
	NSString *url = [@"localhost" completeURLForServerType:CCMHudsonServer];
	STAssertEqualObjects(@"http://localhost/cc.xml", url, @"Should have completed URL.");
}

- (void)testCompletesIntegrationServerURLs
{
	NSArray *urls = [@"http://localhost" completeURLForAllServerTypes];
	STAssertTrue([urls containsObject:@"http://localhost/cctray.xml"], @"Should have returned dashboard URL.");
	STAssertTrue([urls containsObject:@"http://localhost/dashboard/cctray.xml"], @"Should have returned alternate dashboard URL.");
	STAssertTrue([urls containsObject:@"http://localhost/go/cctray.xml"], @"Should have returned Go URL.");
	STAssertTrue([urls containsObject:@"http://localhost/xml"], @"Should have returned classic reporting URL.");
	STAssertTrue([urls containsObject:@"http://localhost/XmlStatusReport.aspx"], @"Should have returned CC.NET URL.");
	STAssertTrue([urls containsObject:@"http://localhost/ccnet/XmlStatusReport.aspx"], @"Should have returned alternate CC.NET URL.");
	STAssertTrue([urls containsObject:@"http://localhost/cc.xml"], @"Should have returned Hudson URL.");
	STAssertTrue([urls containsObject:@"http://localhost/hudson/cc.xml"], @"Should have returned alternate Hudson URL.");
	STAssertEquals(8u, [urls count], @"Should have returned only expected urls.");
}

- (void)testOnlyReturnsOneCompleteURLWhenURLWasComplete
{
	NSArray *urls = [@"localhost/XmlStatusReport.aspx" completeURLForAllServerTypes];
	STAssertTrue([urls containsObject:@"http://localhost/XmlStatusReport.aspx"], @"Should have returned complete URL.");
	STAssertEquals(1u, [urls count], @"Should have returned only one urls.");
}

- (void)testRemovesDashboardFileNameIfPresent
{
	NSString *url = [@"http://localhost/cctray.xml" stringByRemovingServerReportFileName];
	STAssertEqualObjects(@"http://localhost/", url, @"Should have removed filename part from URL.");
}


@end
