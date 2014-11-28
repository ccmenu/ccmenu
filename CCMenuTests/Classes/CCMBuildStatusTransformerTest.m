
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CCMBuildStatusTransformer.h"


@interface CCMBuildStatusTransformerTest : XCTestCase
{
}

@end


@implementation CCMBuildStatusTransformerTest

- (void)testResolvesImage
{
	CCMBuildStatusTransformer *transformer = [[[CCMBuildStatusTransformer alloc] init] autorelease];
	NSImage *testImage = [[[NSImage alloc] init] autorelease];
	OCMockObject *imageFactoryMock = [OCMockObject mockForClass:[CCMImageFactory class]];
	[[[imageFactoryMock expect] andReturn:testImage] imageForStatus:[OCMArg any]];
	[transformer setImageFactory:(id)imageFactoryMock];

	NSImage *returnedImage = [transformer transformedValue:@"test"];
	
	XCTAssertEqual(testImage, returnedImage, @"Should have returned correct image.");
}

@end
