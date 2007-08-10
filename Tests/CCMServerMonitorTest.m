
#import "CCMServerMonitorTest.h"
#import "CCMProject.h"


@implementation CCMServerMonitorTest

- (void)setUp
{
	monitor = [[[CCMServerMonitor alloc] initWithConnection:(id)self] autorelease];
	[monitor setNotificationCenter:(id)self];
	postedNotifications = [NSMutableArray array];
}

- (NSDictionary *)createProjectInfoWithActivity:(NSString *)activity lastBuildStatus:(NSString *)status
{
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:@"connectfour" forKey:@"name"];
	[info setObject:activity forKey:@"activity"];
	[info setObject:status forKey:@"lastBuildStatus"];
	[info setObject:[NSCalendarDate calendarDate] forKey:@"lastBuildDate"];
	return info;
}

- (void)testCreatesProjects
{	
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[monitor pollServer:nil];
	
	NSArray *projectList = [monitor projects];
	STAssertEquals(1u, [projectList count], @"Should have created one project.");
	CCMProject *project = [projectList objectAtIndex:0];
	STAssertEqualObjects(@"connectfour", [project name], @"Should have set up project with right name."); 
	STAssertEqualObjects(CCMSuccessStatus, [project valueForKey:@"lastBuildStatus"], @"Should have set up project projectInfo."); 
}

- (void)testUpdatesProjects
{
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[monitor pollServer:nil];
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	[monitor pollServer:nil];
	
	NSArray *projectList = [monitor projects];
	STAssertEquals(1u, [projectList count], @"Should have created only one project.");
	CCMProject *project = [projectList objectAtIndex:0];
	STAssertEqualObjects(CCMFailedStatus, [project valueForKey:@"lastBuildStatus"], @"Should have updated project projectInfo."); 
}

- (void)testSendsSuccessfulBuildCompleteNotification
{	
	projectInfo = [self createProjectInfoWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus];
	[monitor pollServer:nil];
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[monitor pollServer:nil];
	
	STAssertTrue([postedNotifications count] > 0, @"Should have posted notification.");
	// This next one is a bit dodgy; we're relying on the posting sequence, which we shouldn't.
	NSNotification *notification = [postedNotifications objectAtIndex:1];
	STAssertEqualObjects(CCMBuildCompleteNotification, [notification name], @"Should have posted correct notification.");
	NSDictionary *userInfo = [notification userInfo];
	STAssertEqualObjects(@"connectfour", [userInfo objectForKey:@"projectName"], @"Should have set project name.");
	STAssertEqualObjects(CCMSuccessfulBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testSendsBrokenBuildCompleteNotification
{	
	projectInfo = [self createProjectInfoWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus];
	[monitor pollServer:nil];
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	[monitor pollServer:nil];
	
	NSDictionary *userInfo = [[postedNotifications objectAtIndex:1] userInfo];
	STAssertEqualObjects(CCMBrokenBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testSendsFixedBuildCompleteNotification
{	
	projectInfo = [self createProjectInfoWithActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];
	[monitor pollServer:nil];
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[monitor pollServer:nil];
	
	NSDictionary *userInfo = [[postedNotifications objectAtIndex:1] userInfo];
	STAssertEqualObjects(CCMFixedBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testSendsStillFailingBuildCompleteNotification
{	
	projectInfo = [self createProjectInfoWithActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];
	[monitor pollServer:nil];
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	[monitor pollServer:nil];
	
	NSDictionary *userInfo = [[postedNotifications objectAtIndex:1] userInfo];
	STAssertEqualObjects(CCMStillFailingBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testSendsBrokenBuildCompletionNotificationEvenIfBuildWasMissed
{
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[monitor pollServer:nil];
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	[monitor pollServer:nil];
	
	NSDictionary *userInfo = [[postedNotifications objectAtIndex:1] userInfo];
	STAssertEqualObjects(CCMBrokenBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");	
}

- (void)testSendsFixenBuildCompletionNotificationEvenIfBuildWasMissed
{
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	[monitor pollServer:nil];
	projectInfo = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[monitor pollServer:nil];
	
	NSDictionary *userInfo = [[postedNotifications objectAtIndex:1] userInfo];
	STAssertEqualObjects(CCMFixedBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");	
}


// connection stub

- (NSArray *)getProjectInfos
{
	return [NSArray arrayWithObject:projectInfo];
}

// notification center stub

- (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
	[postedNotifications addObject:[NSNotification notificationWithName:aName object:anObject userInfo:aUserInfo]];
}

@end
