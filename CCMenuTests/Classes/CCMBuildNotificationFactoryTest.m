
#import "CCMBuildNotificationFactoryTest.h"
#import "CCMProject.h"

@implementation CCMBuildNotificationFactoryTest

- (void)setUp
{
	factory = [[[CCMBuildNotificationFactory alloc] init] autorelease];	
}

- (CCMProjectStatus *)createProjectStatusWithActivity:(NSString *)activity lastBuildStatus:(NSString *)status
{
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:activity forKey:@"activity"];
	[info setObject:status forKey:@"lastBuildStatus"];
	[info setObject:[NSCalendarDate calendarDate] forKey:@"lastBuildDate"];
	return [[[CCMProjectStatus alloc] initWithDictionary:info] autorelease];
}

- (CCMProject *)createProjectWithActivity:(NSString *)activity lastBuildStatus:(NSString *)status
{
    CCMProject *project = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
    [project setStatus:[self createProjectStatusWithActivity:activity lastBuildStatus:status]];
    return project;
}

- (void)testCreatesSuccessfulBuildCompleteNotification
{	
	CCMProjectStatus *old = [self createProjectStatusWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus];
    CCMProject *project = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];

	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];
	
	STAssertNotNil(notification, @"Should have created a notification.");
	STAssertEqualObjects(CCMBuildCompleteNotification, [notification name], @"Should have created correct notification.");
    STAssertEquals(project, [notification object], @"Should have set correct notification object.");
	NSDictionary *userInfo = [notification userInfo];
	STAssertEqualObjects(CCMSuccessfulBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testCreatesBrokenBuildCompleteNotification
{	
	CCMProjectStatus *old = [self createProjectStatusWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus];
    CCMProject *project = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
    
	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];

	NSDictionary *userInfo = [notification userInfo];
	STAssertEqualObjects(CCMBrokenBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testCreatesFixedBuildCompleteNotification
{	
	CCMProjectStatus *old = [self createProjectStatusWithActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];
    CCMProject *project = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
    
	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];

	NSDictionary *userInfo = [notification userInfo];
	STAssertEqualObjects(CCMFixedBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testCreatesStillFailingBuildCompleteNotification
{	
	CCMProjectStatus *old = [self createProjectStatusWithActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];
    CCMProject *project = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	
	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];
	
	NSDictionary *userInfo = [notification userInfo];
	STAssertEqualObjects(CCMStillFailingBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testCreatesBrokenBuildCompletionNotificationEvenIfBuildWasMissed
{
	CCMProjectStatus *old = [self createProjectStatusWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
    CCMProject *project = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	
	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];
	
	NSDictionary *userInfo = [notification userInfo];
	STAssertEqualObjects(CCMBrokenBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");	
}

- (void)testCreatesFixedBuildCompletionNotificationEvenIfBuildWasMissed
{
	CCMProjectStatus *old = [self createProjectStatusWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
    CCMProject *project = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	
	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];
	
	NSDictionary *userInfo = [notification userInfo];
	STAssertEqualObjects(CCMFixedBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");	
}

- (void)testCreatesBuildStartingNotification
{
	CCMProjectStatus *old = [self createProjectStatusWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
    CCMProject *project = [self createProjectWithActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];
	
	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];

	STAssertNotNil(notification, @"Should have created a notification.");
	STAssertEqualObjects(CCMBuildStartNotification, [notification name], @"Should have created correct notification.");
    STAssertEquals(project, [notification object], @"Should have set correct notification object.");
}

@end
