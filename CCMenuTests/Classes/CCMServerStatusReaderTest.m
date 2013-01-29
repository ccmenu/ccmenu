
#import "CCMServerStatusReaderTest.h"
#import "CCMServerStatusReader.h"



@implementation CCMServerStatusReaderTest

- (void)testParsesXmlData
{
	NSString *xml = @"<Projects><Project name='connectfour' activity='Sleeping' lastBuildStatus='Success' lastBuildLabel='build.1' lastBuildTime='2007-07-18T18:44:48' webUrl='http://localhost:8080/dashboard/build/detail/connectfour'/></Projects>";
	NSData *data = [xml dataUsingEncoding:NSASCIIStringEncoding];
	CCMServerStatusReader *reader = [[[CCMServerStatusReader alloc] initWithServerResponse:data] autorelease];

	NSArray *infos = [reader readProjectInfos:NULL];
	
    STAssertNotNil(infos, @"Should receive a response.");
    STAssertEquals(1ul, [infos count], @"Response should be an array.");
	
	NSDictionary *info = [infos objectAtIndex:0];
	STAssertEqualObjects(@"connectfour", [info objectForKey:@"name"], @"Should have copied project name.");
	STAssertEqualObjects(@"Sleeping", [info objectForKey:@"activity"], @"Should have copied activity.");
	STAssertEqualObjects(@"Success", [info objectForKey:@"lastBuildStatus"], @"Should have copied status.");
	STAssertEqualObjects(@"build.1", [info objectForKey:@"lastBuildLabel"], @"Should have copied label.");
	STAssertTrue([[info objectForKey:@"lastBuildTime"] isKindOfClass:[NSDate class]], @"Should have returned a date object.");
	STAssertEqualObjects(@"http://localhost:8080/dashboard/build/detail/connectfour", [info objectForKey:@"webUrl"], @"Should have copied web url.");
}

- (void)testReadsDatesWithoutTimezoneAsLocal
{
    NSString *xml = @"<Projects><Project name='connectfour' lastBuildTime='2007-07-18T18:44:48' /></Projects>";
    NSData *data = [xml dataUsingEncoding:NSASCIIStringEncoding];
   	CCMServerStatusReader *reader = [[[CCMServerStatusReader alloc] initWithServerResponse:data] autorelease];

   	NSDictionary *info = [[reader readProjectInfos:NULL] objectAtIndex:0];

    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd HH':'mm':'ss"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *expected = [formatter dateFromString:@"2007-07-18 18:44:48"];
	STAssertEqualObjects(expected, [info objectForKey:@"lastBuildTime"], @"Should have set right last build time.");
}

- (void)testReadsISO8601FormattedDateWithZuluMarker
{
	NSString *xml = @"<Projects><Project name='connectfour' lastBuildTime='2007-07-18T18:44:48Z' /></Projects>";
    NSData *data = [xml dataUsingEncoding:NSASCIIStringEncoding];
	CCMServerStatusReader *reader = [[[CCMServerStatusReader alloc] initWithServerResponse:data] autorelease];

	NSDictionary *info = [[reader readProjectInfos:NULL] objectAtIndex:0];

    NSDate *expected = [NSDate dateWithNaturalLanguageString:@"2007-07-18 18:44:48 UTC"];
	STAssertEqualObjects(expected, [info objectForKey:@"lastBuildTime"], @"Should have set right last build time.");
}

- (void)testReadsISO8601FormattedDateWithTimezone
{
	NSString *xml = @"<Projects><Project name='connectfour' lastBuildTime='2007-07-18T18:44:48+0800' /></Projects>";
    NSData *data = [xml dataUsingEncoding:NSASCIIStringEncoding];
	CCMServerStatusReader *reader = [[[CCMServerStatusReader alloc] initWithServerResponse:data] autorelease];

	NSDictionary *info = [[reader readProjectInfos:NULL] objectAtIndex:0];

    NSDate *expected = [NSDate dateWithNaturalLanguageString:@"2007-07-18 10:44:48 UTC"];
	STAssertEqualObjects(expected, [info objectForKey:@"lastBuildTime"], @"Should have set right last build time.");
}

- (void)testReadsISO8601FormattedDateWithSubsecondsAndTimezoneInAlternateFormat
{
	NSString *xml = @"<Projects><Project name='connectfour' lastBuildTime='2007-07-18T18:44:48.888-05:00' /></Projects>";
    NSData *data = [xml dataUsingEncoding:NSASCIIStringEncoding];
	CCMServerStatusReader *reader = [[[CCMServerStatusReader alloc] initWithServerResponse:data] autorelease];

	NSDictionary *info = [[reader readProjectInfos:NULL] objectAtIndex:0];

    NSDate *expected = [NSDate dateWithNaturalLanguageString:@"2007-07-18 23:44:48 UTC"];
	STAssertEqualObjects(expected, [info objectForKey:@"lastBuildTime"], @"Should have set right last build time.");
}

- (void)testFixesBrokenCruiseControlRbUrls
{
	NSString *xml = @"<Projects><Project name='connectfour' activity='Sleeping' lastBuildStatus='Success' lastBuildLabel='build.1' lastBuildTime='2007-07-18T18:44:48' webUrl='http://localhost:8080/projectsprojects/connectfour'/></Projects>";
	NSData *data = [xml dataUsingEncoding:NSASCIIStringEncoding];
	CCMServerStatusReader *reader = [[[CCMServerStatusReader alloc] initWithServerResponse:data] autorelease];
	
	NSArray *infos = [reader readProjectInfos:NULL];
	
	NSDictionary *info = [infos objectAtIndex:0];
	STAssertEqualObjects(@"http://localhost:8080/projects/connectfour", [info objectForKey:@"webUrl"], @"Should have fixed web url.");
}

- (void)testReturnsParseError
{
	NSString *xml = @"<Projects><Project name='connectfour' deliberately broken";
	NSData *data = [xml dataUsingEncoding:NSASCIIStringEncoding];
	CCMServerStatusReader *reader = [[[CCMServerStatusReader alloc] initWithServerResponse:data] autorelease];
    
    NSError *error = nil;
    NSArray *result = [reader readProjectInfos:&error];
    
    STAssertNil(result, @"Should have returned nil.");
    STAssertNotNil(error, @"Should have set error.");
}

@end
