
#import "CCMBuildStatusTransformerTest.h"
#import "CCMBuildStatusTransformer.h"
#import <OCMock/OCMock.h>


@implementation CCMBuildStatusTransformerTest

- (void)testResolvesImage
{
	CCMBuildStatusTransformer *transformer = [[[CCMBuildStatusTransformer alloc] init] autorelease];
	NSImage *testImage = [[[NSImage alloc] init] autorelease];
	OCMockObject *imageFactoryMock = [OCMockObject mockForClass:[CCMImageFactory class]];
	[[[imageFactoryMock expect] andReturn:testImage] imageForActivity:nil lastBuildStatus:@"test"];
	[transformer setImageFactory:(id)imageFactoryMock];

	NSImage *returnedImage = [transformer transformedValue:@"test"];
	
	STAssertEquals(testImage, returnedImage, @"Should have returned correct image.");
}

@end
