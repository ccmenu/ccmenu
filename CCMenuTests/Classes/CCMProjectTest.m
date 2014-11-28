
#import <XCTest/XCTest.h>
#import "CCMProject.h"


@interface CCMProjectTest : XCTestCase
{
}

@end


@implementation CCMProjectTest

- (void)testTakesStatusFromInfo
{
	CCMProject *project = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
	NSDictionary *info = @{@"bar" : @"foo"};
    
    [project updateWithInfo:info];
    
    XCTAssertNotNil([project status], @"Should have status.");
    XCTAssertNil([project statusError], @"Should not have an error.");    
}

- (void)testHandlesStatusErrors
{
	CCMProject *project = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
	NSDictionary *info = @{@"errorString" : @"test"};
    
    [project updateWithInfo:info];
    
    XCTAssertEqualObjects(@"test", [project statusError], @"Should report error.");
    XCTAssertNil([project status], @"Should not have created status object.");    
}

- (void)testCalculatesEstimatedCompleteTime
{
	CCMProject *project = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
    [project setBuildDuration:@90.0];
    [project setBuildStartTime:[NSDate dateWithNaturalLanguageString:@"2011-07-25 13:47:00"]];

    NSDate *completeTime = [project estimatedBuildCompleteTime];
    
    XCTAssertEqualObjects([NSDate dateWithNaturalLanguageString:@"2011-07-25 13:48:30"], completeTime, @"Should have returned 90s from start");
}

- (void)testDoesNotCalculateEstimatedCompleteTimeWhenNoBuildDurationIsSet
{
	CCMProject *project = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
    [project setBuildStartTime:[NSDate dateWithNaturalLanguageString:@"2011-07-25 13:47:00"]];
    
    NSDate *completeTime = [project estimatedBuildCompleteTime];
    
    XCTAssertNil(completeTime, @"Should have returned nil");
}

@end
