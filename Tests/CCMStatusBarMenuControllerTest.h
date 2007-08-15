
#import <SenTestingKit/SenTestingKit.h>
#import "CCMStatusBarMenuController.h"
#import <OCMock/OCMock.h>


@interface CCMStatusBarMenuControllerTest : SenTestCase 
{
	CCMStatusBarMenuController	*controller;
	NSStatusItem				*statusItem;
	OCMockObject				*imageFactoryMock;
	NSImage						*testImage;
}

@end
