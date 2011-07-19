
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
	NSTimeZone *timezone = [NSTimeZone defaultTimeZone];
	NSCalendarDate *date = [NSCalendarDate dateWithYear:2007 month:7 day:18 hour:18 minute:44 second:48 timeZone:timezone];
	STAssertTrue([[info objectForKey:@"lastBuildTime"] isKindOfClass:[NSCalendarDate class]], @"Should have returned a date object.");
	STAssertEqualObjects(date, [info objectForKey:@"lastBuildTime"], @"Should have set right last build time.");
	STAssertEqualObjects(@"http://localhost:8080/dashboard/build/detail/connectfour", [info objectForKey:@"webUrl"], @"Should have copied web url.");
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
