
#import <SenTestingKit/SenTestingKit.h>
#import "CCMServerMonitor.h"


@interface CCMServerMonitorTest : SenTestCase 
{
	CCMServerMonitor *monitor;
	NSMutableDictionary *projectInfo;
	NSMutableArray *postedNotifications;
}

@end
