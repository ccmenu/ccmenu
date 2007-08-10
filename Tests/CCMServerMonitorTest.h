
#import <SenTestingKit/SenTestingKit.h>
#import "CCMServerMonitor.h"


@interface CCMServerMonitorTest : SenTestCase 
{
	CCMServerMonitor *monitor;
	NSDictionary *projectInfo;
	NSMutableArray *postedNotifications;
}

@end
