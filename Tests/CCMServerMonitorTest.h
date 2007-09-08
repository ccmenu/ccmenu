
#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import "CCMServerMonitor.h"


@interface CCMServerMonitorTest : SenTestCase 
{
	CCMServerMonitor *monitor;
	OCMockObject *defaultsManagerMock;
	NSMutableArray *postedNotifications;
}

@end
