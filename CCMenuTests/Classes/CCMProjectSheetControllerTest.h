
#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import "CCMProjectSheetController.h"


@interface CCMProjectSheetControllerTest : SenTestCase
{
    CCMProjectSheetController *controller;
	
	OCMockObject *defaultsManagerMock;
	OCMockObject *serverUrlComboBoxMock;
	OCMockObject *serverTypeMatrixMock;
}


@end
