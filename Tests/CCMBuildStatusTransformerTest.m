
#import "CCMBuildStatusTransformerTest.h"
#import "CCMBuildStatusTransformer.h"


@implementation CCMBuildStatusTransformerTest

static NSImage *testImage;
static NSString *statusName;

- (void)testResolvesImage
{
	CCMBuildStatusTransformer *transformer = [[[CCMBuildStatusTransformer alloc] init] autorelease];
	[transformer setImageFactory:(id)self];
	testImage = [[[NSImage alloc] init] autorelease];
	NSImage *returnedImage = [transformer transformedValue:@"test"];
	STAssertEquals(@"test", statusName, @"Should have passed parameter to image factory");
	STAssertEquals(testImage, returnedImage, @"Should have returned correct image.");
}


// stub image factory

- (NSImage *)getImageForStatus:(NSString *)name
{
	statusName = name;
	return testImage;
}


@end
