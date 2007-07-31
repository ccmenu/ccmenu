
#import "CCMProjectTest.h"
#import "CCMProject.h"

@implementation CCMProjectTest

- (void)testImplementsValueForKey
{
	CCMProject *project = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
	NSDictionary *info = [NSDictionary dictionaryWithObject:@"Success" forKey:@"lastBuildStatus"];
	[project updateWithInfo:info];
	
	STAssertEquals(@"connectfour", [project valueForKey:@"name"], @"Should have returned right project name.");
	STAssertEquals(@"Success", [project valueForKey:@"lastBuildStatus"], @"Should have returned right build status.");
}

- (void)testParsesFailedStatusString
{
	CCMProject *project = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
	NSDictionary *info = [NSDictionary dictionaryWithObject:CCMFailedStatus forKey:@"lastBuildStatus"];
	[project updateWithInfo:info];

	STAssertTrue([project isFailed], @"Should return YES.");
}

- (void)testReturnsEmptyStringForIntervalWhenProjectHasNeverBeenBuilt
{
	CCMProject *project = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
	NSDictionary *info = [NSDictionary dictionaryWithObject:CCMFailedStatus forKey:@"lastBuildStatus"];
	[project updateWithInfo:info];

	STAssertEqualObjects([project timeSinceLastBuild], @"", @"Should have returned empty string.");
}


@end
