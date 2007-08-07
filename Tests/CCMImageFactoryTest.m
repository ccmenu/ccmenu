
#import "CCMImageFactoryTest.h"
#import "CCMProject.h"


@implementation CCMImageFactoryTest

- (void)setUp
{
	factory = [[[CCMImageFactory alloc] init] autorelease];
}

- (void)testReturnsLastBuildSuccessfulSleepingImage
{
//	TODO: I would have preferred tests like this but for some reason I can't seem to set the image names
//	NSImage *image = [factory imageForActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
//	STAssertEqualObjects(@"icon-success-menu", [image name], @"Should have loaded correct image.");
}

- (void)testNameForLastBuildSuccessfulSleepingImage
{
	NSString *name = [factory imageNameForActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	STAssertEqualObjects(@"icon-success.png", name, @"Should have loaded correct image.");
}

- (void)testNameForLastBuildFailedSleepingImage
{
	NSString *name = [factory imageNameForActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	STAssertEqualObjects(@"icon-failure.png", name, @"Should have loaded correct image.");
}

- (void)testNameForLastBuildSuccessfulOtherActivityImage
{
	NSString *name = [factory imageNameForActivity:@"foo" lastBuildStatus:CCMSuccessStatus];
	STAssertEqualObjects(@"icon-success.png", name, @"Should have loaded correct image.");
}

- (void)testNameForLastBuildSuccessfulBuildingImage
{
	NSString *name = [factory imageNameForActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus];
	STAssertEqualObjects(@"icon-success-building.png", name, @"Should have loaded correct image.");
}

- (void)testNameForLastBuildFailedBuildingImage
{
	NSString *name = [factory imageNameForActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];
	STAssertEqualObjects(@"icon-failure-building.png", name, @"Should have loaded correct image.");
}

@end
