
#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import "CCMAddProjectsController.h"


@interface CCMAddProjectsControllerTest : SenTestCase
{
    CCMAddProjectsController *controller;
	
	OCMockObject *defaultsManagerMock;
	OCMockObject *serverUrlComboBoxMock;
	OCMockObject *serverTypeMatrixMock;
}


@end
