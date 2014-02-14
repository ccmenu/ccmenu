
#import "CCMProjectStatusTest.h"
#import "CCMProjectStatus.h"


@implementation CCMProjectStatusTest

- (void)testCanCallMethodsForInfoKeys
{
	NSDictionary *info = [NSDictionary dictionaryWithObject:@"Success" forKey:@"lastBuildStatus"];
	CCMProjectStatus *status = [[[CCMProjectStatus alloc] initWithDictionary:info] autorelease];
	
	STAssertEquals(@"Success", [status lastBuildStatus], @"Should have returned right build status.");
}

- (void)testRaisesUnknownMethodExceptionForMethodsNotCorrespondingToInfoKeys
{
	NSDictionary *info = [NSDictionary dictionaryWithObject:@"Success" forKey:@"lastBuildStatus"];
	CCMProjectStatus *status = [[[CCMProjectStatus alloc] initWithDictionary:info] autorelease];
	
	STAssertThrows([(id)status lowercaseString], @"Should have thrown an exception.");
}

- (void)testImplementsKeyValueCoding
{
	NSDictionary *info = [NSDictionary dictionaryWithObject:@"Success" forKey:@"lastBuildStatus"];
	CCMProjectStatus *status = [[[CCMProjectStatus alloc] initWithDictionary:info] autorelease];
	
	STAssertEquals(@"Success", [status valueForKey:@"lastBuildStatus"], @"Should have returned right build status.");
}

- (void)testBuildStatusSuccessConsideredSuccessfulBuild
{
    NSDictionary *info = @{ @"lastBuildStatus": @"Success" };
    CCMProjectStatus *status = [[[CCMProjectStatus alloc] initWithDictionary:info] autorelease];

    STAssertTrue([status buildWasSuccessful], @"Should have considered build successful.");
}

- (void)testBuildStatusFailureConsideredFailedBuild
{
    NSDictionary *info = @{ @"lastBuildStatus": @"Failure" };
    CCMProjectStatus *status = [[[CCMProjectStatus alloc] initWithDictionary:info] autorelease];

    STAssertTrue([status buildDidFail], @"Should have considered build failed.");
}

- (void)testBuildStatusErrorConsideredFailedBuild
{
    NSDictionary *info = @{ @"lastBuildStatus": @"Error" };
    CCMProjectStatus *status = [[[CCMProjectStatus alloc] initWithDictionary:info] autorelease];

    STAssertTrue([status buildDidFail], @"Should have considered build failed.");
}

- (void)testBuildStatusUnknownConsideredNeitherFailedNorSuccessfulBuild
{
    NSDictionary *info = @{ @"lastBuildStatus": @"Unknown" };
    CCMProjectStatus *status = [[[CCMProjectStatus alloc] initWithDictionary:info] autorelease];

    STAssertFalse([status buildWasSuccessful], @"Should not have considered build successful.");
    STAssertFalse([status buildDidFail], @"Should not have considered build failed.");
}

- (void)testNilBuildStatusConsideredNeitherFailedNorSuccessfulBuild
{
    NSDictionary *info = @{ };
    CCMProjectStatus *status = [[[CCMProjectStatus alloc] initWithDictionary:info] autorelease];

    STAssertFalse([status buildWasSuccessful], @"Should not have considered build successful.");
    STAssertFalse([status buildDidFail], @"Should not have considered build failed.");
}

@end
