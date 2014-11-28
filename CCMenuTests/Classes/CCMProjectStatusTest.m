
#import <XCTest/XCTest.h>
#import "CCMProjectStatus.h"


@interface CCMProjectStatusTest : XCTestCase
{
}

@end


@implementation CCMProjectStatusTest

- (void)testCanCallMethodsForInfoKeys
{
	NSDictionary *info = @{@"lastBuildStatus" : @"Success"};
	CCMProjectStatus *status = [[[CCMProjectStatus alloc] initWithDictionary:info] autorelease];
	
	XCTAssertEqual(@"Success", [status lastBuildStatus], @"Should have returned right build status.");
}

- (void)testRaisesUnknownMethodExceptionForMethodsNotCorrespondingToInfoKeys
{
	NSDictionary *info = @{@"lastBuildStatus" : @"Success"};
	CCMProjectStatus *status = [[[CCMProjectStatus alloc] initWithDictionary:info] autorelease];
	
	XCTAssertThrows([(id)status lowercaseString], @"Should have thrown an exception.");
}

- (void)testImplementsKeyValueCoding
{
	NSDictionary *info = @{@"lastBuildStatus" : @"Success"};
	CCMProjectStatus *status = [[[CCMProjectStatus alloc] initWithDictionary:info] autorelease];
	
	XCTAssertEqual(@"Success", [status valueForKey:@"lastBuildStatus"], @"Should have returned right build status.");
}

- (void)testBuildStatusSuccessConsideredSuccessfulBuild
{
    NSDictionary *info = @{ @"lastBuildStatus": @"Success" };
    CCMProjectStatus *status = [[[CCMProjectStatus alloc] initWithDictionary:info] autorelease];

    XCTAssertTrue([status buildWasSuccessful], @"Should have considered build successful.");
}

- (void)testBuildStatusFailureConsideredFailedBuild
{
    NSDictionary *info = @{ @"lastBuildStatus": @"Failure" };
    CCMProjectStatus *status = [[[CCMProjectStatus alloc] initWithDictionary:info] autorelease];

    XCTAssertTrue([status buildDidFail], @"Should have considered build failed.");
}

- (void)testBuildStatusErrorConsideredFailedBuild
{
    NSDictionary *info = @{ @"lastBuildStatus": @"Error" };
    CCMProjectStatus *status = [[[CCMProjectStatus alloc] initWithDictionary:info] autorelease];

    XCTAssertTrue([status buildDidFail], @"Should have considered build failed.");
}

- (void)testBuildStatusUnknownConsideredNeitherFailedNorSuccessfulBuild
{
    NSDictionary *info = @{ @"lastBuildStatus": @"Unknown" };
    CCMProjectStatus *status = [[[CCMProjectStatus alloc] initWithDictionary:info] autorelease];

    XCTAssertFalse([status buildWasSuccessful], @"Should not have considered build successful.");
    XCTAssertFalse([status buildDidFail], @"Should not have considered build failed.");
}

- (void)testNilBuildStatusConsideredNeitherFailedNorSuccessfulBuild
{
    NSDictionary *info = @{ };
    CCMProjectStatus *status = [[[CCMProjectStatus alloc] initWithDictionary:info] autorelease];

    XCTAssertFalse([status buildWasSuccessful], @"Should not have considered build successful.");
    XCTAssertFalse([status buildDidFail], @"Should not have considered build failed.");
}

@end
