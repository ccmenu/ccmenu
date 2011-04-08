
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
	STAssertEqualObjects(@"icon-success", [image name], @"Should have loaded correct image.");
}

- (void)testLastBuildFailedSleepingImage
{
	NSImage *image = [factory imageForActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	STAssertEqualObjects(@"icon-failure", [image name], @"Should have loaded correct image.");
}

- (void)testLastBuildSuccessfulOtherActivityImage
{
	NSImage *image = [factory imageForActivity:@"some random activity" lastBuildStatus:CCMSuccessStatus];
	STAssertEqualObjects(@"icon-success", [image name], @"Should have loaded correct image.");
}

- (void)testLastBuildSuccessfulBuildingImage
{
	NSImage *image = [factory imageForActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus];
	STAssertEqualObjects(@"icon-success-building", [image name], @"Should have loaded correct image.");
}

- (void)testLastBuildFailedBuildingImage
{
	NSImage *image = [factory imageForActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];
	STAssertEqualObjects(@"icon-failure-building", [image name], @"Should have loaded correct image.");
}

- (void)testNoBuildStatusImage
{
	NSImage *image = [factory imageForActivity:@"foo" lastBuildStatus:nil];
	STAssertEqualObjects(@"icon-inactive", [image name], @"Should have loaded correct image.");
}

- (void)testInvalidBuildStatusImage
{
	NSImage *image = [factory imageForActivity:CCMSleepingActivity lastBuildStatus:@"Exception"];
	STAssertEqualObjects(@"icon-failure", [image name], @"Should have loaded correct image.");
}

- (void)testCachesMenuImages
{
	NSImage *original = [[NSImage alloc] init];
	STAssertTrue([original setName:@"testCachesMenuImages"], @"Should have been able to set image name.");
	NSImage *menu1 = [factory convertForMenuUse:original];
	STAssertTrue(![[menu1 name] isEqualToString:[original name]], @"Should have used different name.");
	NSImage *menu2 = [factory convertForMenuUse:original];
	STAssertTrue(menu1 == menu2, @"Should have reused same image object.");
}

@end
