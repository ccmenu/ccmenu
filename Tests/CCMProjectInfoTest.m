
#import "CCMProjectInfoTest.h"
#import "CCMProjectInfo.h"

@implementation CCMProjectInfoTest

- (void)testCreatesInfosFromXml
{
	NSData *xml = [NSData dataWithContentsOfFile:@"Tests/cctray.xml"];
	STAssertNotNil(xml, @"No test data?!");
	
	NSArray *infoList = [CCMProjectInfo infosFromXmlData:xml];
	STAssertEquals((unsigned)7, [infoList count], @"Should have found right number of projects.");

	CCMProjectInfo *info = [infoList objectAtIndex:0];
	STAssertEqualObjects(@"cclive-contrib-distributed-jdk1.5", [info projectName], @"Should have set right project name.");
	STAssertEqualObjects(@"Success", [info buildStatus], @"Should have set right project status.");
	
//	NSTimeZone *timezone = [NSTimeZone timeZoneWithName:@"GMT -05:00"];
	NSTimeZone *timezone = [NSTimeZone defaultTimeZone];
	NSCalendarDate *date = [NSCalendarDate dateWithYear:2007 month:6 day:29 hour:16 minute:45 second:24 timeZone:timezone];
	STAssertTrue([[info lastBuildDate] isKindOfClass:[NSCalendarDate class]], @"Should have returned a date object.");
	STAssertEqualObjects(date, [info lastBuildDate], @"Should have set right last build time.");
}

- (void)testParsesFailedStatusString
{
	CCMProjectInfo *info = [[[CCMProjectInfo alloc] initWithProjectName:nil buildStatus:CCMFailedStatus lastBuildDate:nil] autorelease];
	STAssertTrue([info isFailed], @"Should return YES.");
}

- (void)testReturnsEmptyStringForIntervalWhenProjectHasNeverBeenBuilt
{
	CCMProjectInfo *info = [[[CCMProjectInfo alloc] initWithProjectName:nil buildStatus:CCMFailedStatus lastBuildDate:nil] autorelease];
	STAssertEqualObjects([info timeSinceLastBuild], @"", @"Should have returned empty string.");
}


@end
