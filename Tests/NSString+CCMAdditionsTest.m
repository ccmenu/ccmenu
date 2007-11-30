
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

- (void)testComplesCruiseControlClassicURLs
{
	NSString *url = [@"localhost" completeCruiseControlURLForServerType:CCMCruiseControlClassic];
	STAssertEqualObjects(@"http://localhost/xml", url, @"Should have completed URL.");
}

- (void)testComplesCruiseControlDotNetURLs
{
	NSString *url = [@"localhost" completeCruiseControlURLForServerType:CCMCruiseControlDotNetServer];
	STAssertEqualObjects(@"http://localhost/XmlStatusReport.aspx", url, @"Should have completed URL.");
}

- (void)testRemovesDashboardFileNameIfPresent
{
	NSString *url = [@"http://localhost/cctray.xml" stringByRemovingCruiseControlReportFileName];
	STAssertEqualObjects(@"http://localhost/", url, @"Should have removed filename part from URL.");
}


@end
