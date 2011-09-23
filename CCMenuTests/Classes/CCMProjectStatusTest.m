
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

@end
