
#import "CCMBuildNotificationFactoryTest.h"
#import "CCMServerMonitor.h"

@implementation CCMBuildNotificationFactoryTest

- (void)setUp
{
	factory = [[[CCMBuildNotificationFactory alloc] init] autorelease];	
	project = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
}

- (NSMutableDictionary *)createProjectInfoWithActivity:(NSString *)activity lastBuildStatus:(NSString *)status
{
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:@"connectfour" forKey:@"name"];
	[info setObject:activity forKey:@"activity"];
	[info setObject:status forKey:@"lastBuildStatus"];
	[info setObject:[NSCalendarDate calendarDate] forKey:@"lastBuildDate"];
	return info;
}

- (void)testCreatesSuccessfulBuildCompleteNotification
{	
	NSDictionary *pi1 = [self createProjectInfoWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus];
	NSDictionary *pi2 = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[project updateWithInfo:pi1];

	NSNotification *notification = [factory buildCompleteNotificationForProject:project andNewInfo:pi2];
	
	STAssertNotNil(notification, @"Should have created a notification.");
	STAssertEqualObjects(CCMBuildCompleteNotification, [notification name], @"Should have created correct notification.");
	NSDictionary *userInfo = [notification userInfo];
	STAssertEqualObjects(@"connectfour", [userInfo objectForKey:@"projectName"], @"Should have set project name.");
	STAssertEqualObjects(CCMSuccessfulBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testCreatesBrokenBuildCompleteNotification
{	
	NSDictionary *pi1 = [self createProjectInfoWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus];
	NSDictionary *pi2 = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	[project updateWithInfo:pi1];
	
	NSNotification *notification = [factory buildCompleteNotificationForProject:project andNewInfo:pi2];
	
	NSDictionary *userInfo = [notification userInfo];
	STAssertEqualObjects(CCMBrokenBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testCreatesFixedBuildCompleteNotification
{	
	NSDictionary *pi1 = [self createProjectInfoWithActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];
	NSDictionary *pi2 = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[project updateWithInfo:pi1];
	
	NSNotification *notification = [factory buildCompleteNotificationForProject:project andNewInfo:pi2];
	
	NSDictionary *userInfo = [notification userInfo];
	STAssertEqualObjects(CCMFixedBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testCreatesStillFailingBuildCompleteNotification
{	
	NSDictionary *pi1 = [self createProjectInfoWithActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];
	NSDictionary *pi2 = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	[project updateWithInfo:pi1];
	
	NSNotification *notification = [factory buildCompleteNotificationForProject:project andNewInfo:pi2];
	
	NSDictionary *userInfo = [notification userInfo];
	STAssertEqualObjects(CCMStillFailingBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testCreatesBrokenBuildCompletionNotificationEvenIfBuildWasMissed
{
	NSDictionary *pi1 = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	NSDictionary *pi2 = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	[project updateWithInfo:pi1];
	
	NSNotification *notification = [factory buildCompleteNotificationForProject:project andNewInfo:pi2];
	
	NSDictionary *userInfo = [notification userInfo];
	STAssertEqualObjects(CCMBrokenBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");	
}

- (void)testCreatesFixedBuildCompletionNotificationEvenIfBuildWasMissed
{
	NSDictionary *pi1 = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	NSDictionary *pi2 = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[project updateWithInfo:pi1];
	
	NSNotification *notification = [factory buildCompleteNotificationForProject:project andNewInfo:pi2];
	
	NSDictionary *userInfo = [notification userInfo];
	STAssertEqualObjects(CCMFixedBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");	
}

@end
