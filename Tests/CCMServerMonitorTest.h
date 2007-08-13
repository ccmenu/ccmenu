
#import <SenTestingKit/SenTestingKit.h>
#import "CCMServerMonitor.h"


@interface CCMServerMonitorTest : SenTestCase 
{
	CCMServerMonitor *monitor;
	NSMutableArray *projectsUserDefaults;
	NSMutableArray *postedNotifications;
}

@end
