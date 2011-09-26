
#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import "CCMServerMonitor.h"


@interface CCMServerMonitorTest : SenTestCase 
{
	CCMServerMonitor *monitor;
	id               defaultsManagerMock;
    id               notificationFactoryMock;
    id               notificationCenterMock;
}

@end
