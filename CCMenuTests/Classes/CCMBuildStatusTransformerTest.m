
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
	id imageFactoryMock = OCMClassMock([CCMImageFactory class]);
    OCMStub([imageFactoryMock imageForStatus:[OCMArg any]]).andReturn(testImage);
	[transformer setImageFactory:imageFactoryMock];

	NSImage *returnedImage = [transformer transformedValue:@"test"];
	
	XCTAssertEqual(testImage, returnedImage, @"Should have returned correct image.");
}

@end
