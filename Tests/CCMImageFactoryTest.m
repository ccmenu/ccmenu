
#import "CCMImageFactoryTest.h"
#import "CCMProject.h"


@implementation CCMImageFactoryTest

- (void)setUp
{
	factory = [[[CCMImageFactory alloc] init] autorelease];
}

- (void)testLastBuildSuccessfulSleepingImage
{
	NSImage *image = [factory imageForActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	STAssertEqualObjects(@"icon-success.png", [image name], @"Should have loaded correct image.");
}

- (void)testLastBuildFailedSleepingImage
{
	NSImage *image = [factory imageForActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	STAssertEqualObjects(@"icon-failure.png", [image name], @"Should have loaded correct image.");
}

- (void)testLastBuildSuccessfulOtherActivityImage
{
	NSImage *image = [factory imageForActivity:@"some random activity" lastBuildStatus:CCMSuccessStatus];
	STAssertEqualObjects(@"icon-success.png", [image name], @"Should have loaded correct image.");
}

- (void)testLastBuildSuccessfulBuildingImage
{
	NSImage *image = [factory imageForActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus];
	STAssertEqualObjects(@"icon-success-building.png", [image name], @"Should have loaded correct image.");
}

- (void)testNameForLastBuildFailedBuildingImage
{
	NSImage *image = [factory imageForActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];
	STAssertEqualObjects(@"icon-failure-building.png", [image name], @"Should have loaded correct image.");
}

- (void)testCachesMenuImages
{
	NSImage *original = [[NSImage alloc] init];
	STAssertTrue([original setName:@"testCachesMenuImages"], @"Should have been able to set image name.");
	NSImage *menu1 = [factory convertForMenuUse:original];
	STAssertEqualObjects(@"testCachesMenuImages-menu", [menu1 name], @"Should have been able to set image name.");
	NSImage *menu2 = [factory convertForMenuUse:original];
	STAssertTrue(menu1 == menu2, @"Should have reused same image object.");
}

@end
