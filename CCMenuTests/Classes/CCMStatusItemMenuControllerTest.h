
#import <SenTestingKit/SenTestingKit.h>
#import "CCMStatusItemMenuController.h"
#import <OCMock/OCMock.h>


@interface CCMStatusItemMenuControllerTest : SenTestCase 
{
	CCMStatusItemMenuController		*controller;
	NSStatusItem					*statusItem;
	OCMockObject					*imageFactoryMock;
	NSImage							*testImage;
}

@end
