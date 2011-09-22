
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
    STAssertEquals(1u, [infos count], @"Response should be an array.");
	
	NSDictionary *info = [infos objectAtIndex:0];
	STAssertEqualObjects(@"connectfour", [info objectForKey:@"name"], @"Should have copied project name.");
	STAssertEqualObjects(@"Sleeping", [info objectForKey:@"activity"], @"Should have copied activity.");
	STAssertEqualObjects(@"Success", [info objectForKey:@"lastBuildStatus"], @"Should have copied status.");
	STAssertEqualObjects(@"build.1", [info objectForKey:@"lastBuildLabel"], @"Should have copied label.");
	STAssertTrue([[info objectForKey:@"lastBuildTime"] isKindOfClass:[NSDate class]], @"Should have returned a date object.");
    NSDate *expected = [NSDate dateWithNaturalLanguageString:@"2007-07-18 18:44:48 GMT"];
	STAssertEqualObjects(expected, [info objectForKey:@"lastBuildTime"], @"Should have set right last build time.");
	STAssertEqualObjects(@"http://localhost:8080/dashboard/build/detail/connectfour", [info objectForKey:@"webUrl"], @"Should have copied web url.");
}

- (void)testReadsIsoFormattedDateWithUtcMarker
{
	NSString *xml = @"<Projects><Project name='connectfour' lastBuildTime='2007-07-18T18:44:48Z' /></Projects>";
    NSData *data = [xml dataUsingEncoding:NSASCIIStringEncoding];
	CCMServerStatusReader *reader = [[[CCMServerStatusReader alloc] initWithServerResponse:data] autorelease];
    
	NSArray *infos = [reader readProjectInfos:NULL];
    
//    NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSISO8601Calendar] autorelease];
    NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
    [components setYear:2007]; [components setMonth:7]; [components setDay:18];
    [components setHour:18]; [components setMinute:44]; [components setSecond:48];
    NSDate *expected = [calendar dateFromComponents:components];
	STAssertEqualObjects(expected, [[infos objectAtIndex:0] objectForKey:@"lastBuildTime"], @"Should have set right last build time.");
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
