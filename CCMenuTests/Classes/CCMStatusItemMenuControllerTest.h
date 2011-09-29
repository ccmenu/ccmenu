
#import <SenTestingKit/SenTestingKit.h>
#import "CCMStatusItemMenuController.h"
#import <OCMock/OCMock.h>


@interface CCMStatusItemMenuControllerTest : SenTestCase 
{
	CCMStatusItemMenuController	*controller;
	NSImage						*dummyImage;
	
    id                          serverMonitorMock;
    id                          imageFactoryMock;
}

@end
