
#import "CCMProjectTest.h"
#import "CCMProject.h"


@implementation CCMProjectTest

- (void)testTakesStatusFromInfo
{
	CCMProject *project = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
	NSDictionary *info = [NSDictionary dictionaryWithObject:@"foo" forKey:@"bar"];
    
    [project updateWithInfo:info];
    
    STAssertNotNil([project status], @"Should have status.");
    STAssertNil([project statusError], @"Should not have an error.");    
}

- (void)testHandlesStatusErrors
{
	CCMProject *project = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
	NSDictionary *info = [NSDictionary dictionaryWithObject:@"test" forKey:@"errorString"];
    
    [project updateWithInfo:info];
    
    STAssertEqualObjects(@"test", [project statusError], @"Should report error.");
    STAssertNil([project status], @"Should not have created status object.");    
}

- (void)testCalculatesEstimatedCompleteTime
{
	CCMProject *project = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
    [project setBuildDuration:[NSNumber numberWithDouble:90.0]];
    [project setBuildStartTime:[NSDate dateWithNaturalLanguageString:@"2011-07-25 13:47:00"]];

    NSDate *completeTime = [project estimatedBuildCompleteTime];
    
    STAssertEqualObjects([NSDate dateWithNaturalLanguageString:@"2011-07-25 13:48:30"], completeTime, @"Should have returned 90s from start");
}

- (void)testDoesNotCalculateEstimatedCompleteTimeWhenNoBuildDurationIsSet
{
	CCMProject *project = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
    [project setBuildStartTime:[NSDate dateWithNaturalLanguageString:@"2011-07-25 13:47:00"]];
    
    NSDate *completeTime = [project estimatedBuildCompleteTime];
    
    STAssertNil(completeTime, @"Should have returned nil");
}

@end
