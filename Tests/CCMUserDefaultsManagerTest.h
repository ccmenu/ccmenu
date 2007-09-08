
#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import "CCMUserDefaultsManager.h"


@interface CCMUserDefaultsManagerTest : SenTestCase 
{
	CCMUserDefaultsManager	*manager;
	OCMockObject			*defaultsMock;
}

@end
