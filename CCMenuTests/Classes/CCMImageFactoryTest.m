
#import <XCTest/XCTest.h>
#import "CCMImageFactory.h"
#import "CCMProject.h"


@interface CCMImageFactoryTest : XCTestCase
{
	CCMImageFactory *factory;
}

@end


@implementation CCMImageFactoryTest

- (void)setUp
{
	factory = [[[CCMImageFactory alloc] init] autorelease];
}

- (void)testLastBuildSuccessfulSleepingImage
{
    NSDictionary *d = @{ @"activity": @"Sleeping", @"lastBuildStatus": @"Success" };
    NSImage *image = [factory imageForStatus:[CCMProjectStatus statusWithDictionary:d]];
    XCTAssertEqualObjects(@"icon-success", [image name], @"Should have loaded correct image.");
}

- (void)testLastBuildFailedSleepingImage
{
    NSDictionary *d = @{ @"activity": @"Sleeping", @"lastBuildStatus": @"Failure" };
    NSImage *image = [factory imageForStatus:[CCMProjectStatus statusWithDictionary:d]];
	XCTAssertEqualObjects(@"icon-failure", [image name], @"Should have loaded correct image.");
}

- (void)testLastBuildSuccessfulBuildingImage
{
    NSDictionary *d = @{ @"activity": @"Building", @"lastBuildStatus": @"Success" };
    NSImage *image = [factory imageForStatus:[CCMProjectStatus statusWithDictionary:d]];
    XCTAssertEqualObjects(@"icon-success-building", [image name], @"Should have loaded correct image.");
}

- (void)testLastBuildFailedBuildingImage
{
    NSDictionary *d = @{ @"activity": @"Building", @"lastBuildStatus": @"Failure" };
    NSImage *image = [factory imageForStatus:[CCMProjectStatus statusWithDictionary:d]];
	XCTAssertEqualObjects(@"icon-failure-building", [image name], @"Should have loaded correct image.");
}

- (void)testLastBuildNeitherSuccessfulNorFailedBuildingImage
{
    NSDictionary *d = @{ @"activity": @"Building", @"lastBuildStatus": @"Unknown" };
    NSImage *image = [factory imageForStatus:[CCMProjectStatus statusWithDictionary:d]];
    XCTAssertEqualObjects(@"icon-success-building", [image name], @"Should have loaded correct image.");
}

- (void)testLastBuildSuccessfulOtherActivityImage
{
    NSDictionary *d = @{ @"activity": @"some random activity", @"lastBuildStatus": @"Success" };
    NSImage *image = [factory imageForStatus:[CCMProjectStatus statusWithDictionary:d]];
    XCTAssertEqualObjects(@"icon-success", [image name], @"Should have loaded correct image.");
}

- (void)testLastBuildStatusIsUnknownImage
{
    // Jenkins uses "unknown" for builds that are inactive
    NSDictionary *d = @{ @"lastBuildStatus": @"Unknown" };
    NSImage *image = [factory imageForStatus:[CCMProjectStatus statusWithDictionary:d]];
    XCTAssertEqualObjects(@"icon-pause", [image name], @"Should have loaded correct image.");
}

- (void)testNoBuildStatusImage
{
    NSDictionary *d = @{ @"activity": @"some random activity"};
    NSImage *image = [factory imageForStatus:[CCMProjectStatus statusWithDictionary:d]];
	XCTAssertEqualObjects(@"icon-inactive", [image name], @"Should have loaded correct image.");
}

- (void)testUnexpectedBuildStatusImage
{
    NSDictionary *d = @{ @"lastBuildStatus": @"Exception" };
    NSImage *image = [factory imageForStatus:[CCMProjectStatus statusWithDictionary:d]];
	// note: different to old behaviour
    XCTAssertEqualObjects(@"icon-inactive", [image name], @"Should have loaded correct image.");
}


- (void)testCachesMenuImages
{
	NSImage *original = [[[NSImage alloc] init] autorelease];
	XCTAssertTrue([original setName:@"testCachesMenuImages"], @"Should have been able to set image name.");
	NSImage *menu1 = [factory convertForMenuUse:original];
	XCTAssertTrue(![[menu1 name] isEqualToString:[original name]], @"Should have used different name.");
	NSImage *menu2 = [factory convertForMenuUse:original];
	XCTAssertTrue(menu1 == menu2, @"Should have reused same image object.");
}

@end
