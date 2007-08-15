
#import "CCMProjectRepositoryTest.h"
#import "CCMProject.h"
#import <OCMock/OCMock.h>


@implementation CCMProjectRepositoryTest

- (void)setUp
{
	NSArray *projects = [NSArray arrayWithObject:@"connectfour"];
	postedNotifications = [NSMutableArray array];

	connectionMock = [OCMockObject mockForClass:[CCMConnection class]];
	repository = [[[CCMProjectRepository alloc] initWithConnection:(id)connectionMock andProjects:projects] autorelease];	
	[repository setNotificationCenter:(id)self];
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

- (void)testCreatesProjects
{	
	NSDictionary *pi = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[[[connectionMock expect] andReturn:[NSArray arrayWithObject:pi]] getProjectInfos];

	[repository pollServer];
	
	NSArray *projectList = [repository projects];
	STAssertEquals(1u, [projectList count], @"Should have created one project.");
	CCMProject *project = [projectList objectAtIndex:0];
	STAssertEqualObjects(@"connectfour", [project name], @"Should have set up project with right name."); 
	STAssertEqualObjects(CCMSuccessStatus, [project valueForKey:@"lastBuildStatus"], @"Should have set up project projectInfo."); 
}

- (void)testIgnoresProjectsNotInInitialList
{	
	NSDictionary *pi1 = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	NSMutableDictionary *pi2 = [[self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus] mutableCopy];
	[pi2 setObject:@"foo" forKey:@"name"];
	[[[connectionMock expect] andReturn:[NSArray arrayWithObjects:pi1, pi2, nil]] getProjectInfos];
	[repository pollServer];

	NSArray *projectList = [repository projects];
	STAssertEquals(1u, [projectList count], @"Should have ignored additional project.");
	CCMProject *project = [projectList objectAtIndex:0];
	STAssertEqualObjects(@"connectfour", [project name], @"Should have kept project with right name."); 
}

- (void)testUpdatesProjects
{
	NSDictionary *pi1 = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[[[connectionMock expect] andReturn:[NSArray arrayWithObject:pi1]] getProjectInfos];
	[repository pollServer];
	NSDictionary *pi2 = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	[[[connectionMock expect] andReturn:[NSArray arrayWithObject:pi2]] getProjectInfos];
	[repository pollServer];
	
	NSArray *projectList = [repository projects];
	STAssertEquals(1u, [projectList count], @"Should have created only one project.");
	CCMProject *project = [projectList objectAtIndex:0];
	STAssertEqualObjects(CCMFailedStatus, [project valueForKey:@"lastBuildStatus"], @"Should have updated project projectInfo."); 
}

- (void)testSendsSuccessfulBuildCompleteNotification
{	
	NSDictionary *pi1 = [self createProjectInfoWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus];
	[[[connectionMock expect] andReturn:[NSArray arrayWithObject:pi1]] getProjectInfos];
	[repository pollServer];
	NSDictionary *pi2 = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[[[connectionMock expect] andReturn:[NSArray arrayWithObject:pi2]] getProjectInfos];
	[repository pollServer];
	
	STAssertTrue([postedNotifications count] > 0, @"Should have posted notification.");
	NSNotification *notification = [postedNotifications objectAtIndex:0];
	STAssertEqualObjects(CCMBuildCompleteNotification, [notification name], @"Should have posted correct notification.");
	NSDictionary *userInfo = [notification userInfo];
	STAssertEqualObjects(@"connectfour", [userInfo objectForKey:@"projectName"], @"Should have set project name.");
	STAssertEqualObjects(CCMSuccessfulBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testSendsBrokenBuildCompleteNotification
{	
	NSDictionary *pi1 = [self createProjectInfoWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus];
	[[[connectionMock expect] andReturn:[NSArray arrayWithObject:pi1]] getProjectInfos];
	[repository pollServer];
	NSDictionary *pi2 = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	[[[connectionMock expect] andReturn:[NSArray arrayWithObject:pi2]] getProjectInfos];
	[repository pollServer];

	NSDictionary *userInfo = [[postedNotifications objectAtIndex:0] userInfo];
	STAssertEqualObjects(CCMBrokenBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testSendsFixedBuildCompleteNotification
{	
	NSDictionary *pi1 = [self createProjectInfoWithActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];
	[[[connectionMock expect] andReturn:[NSArray arrayWithObject:pi1]] getProjectInfos];
	[repository pollServer];
	NSDictionary *pi2 = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[[[connectionMock expect] andReturn:[NSArray arrayWithObject:pi2]] getProjectInfos];
	[repository pollServer];

	NSDictionary *userInfo = [[postedNotifications objectAtIndex:0] userInfo];
	STAssertEqualObjects(CCMFixedBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testSendsStillFailingBuildCompleteNotification
{	
	NSDictionary *pi1 = [self createProjectInfoWithActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];
	[[[connectionMock expect] andReturn:[NSArray arrayWithObject:pi1]] getProjectInfos];
	[repository pollServer];
	NSDictionary *pi2 = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	[[[connectionMock expect] andReturn:[NSArray arrayWithObject:pi2]] getProjectInfos];
	[repository pollServer];

	NSDictionary *userInfo = [[postedNotifications objectAtIndex:0] userInfo];
	STAssertEqualObjects(CCMStillFailingBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testSendsBrokenBuildCompletionNotificationEvenIfBuildWasMissed
{
	NSDictionary *pi1 = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[[[connectionMock expect] andReturn:[NSArray arrayWithObject:pi1]] getProjectInfos];
	[repository pollServer];
	NSDictionary *pi2 = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	[[[connectionMock expect] andReturn:[NSArray arrayWithObject:pi2]] getProjectInfos];
	[repository pollServer];

	NSDictionary *userInfo = [[postedNotifications objectAtIndex:0] userInfo];
	STAssertEqualObjects(CCMBrokenBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");	
}

- (void)testSendsFixedBuildCompletionNotificationEvenIfBuildWasMissed
{
	NSDictionary *pi1 = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	[[[connectionMock expect] andReturn:[NSArray arrayWithObject:pi1]] getProjectInfos];
	[repository pollServer];
	NSDictionary *pi2 = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[[[connectionMock expect] andReturn:[NSArray arrayWithObject:pi2]] getProjectInfos];
	[repository pollServer];

	NSDictionary *userInfo = [[postedNotifications objectAtIndex:0] userInfo];
	STAssertEqualObjects(CCMFixedBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");	
}


// notification center stub (need this until next version of OCMock, which will have constraints)

- (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
	[postedNotifications addObject:[NSNotification notificationWithName:aName object:anObject userInfo:aUserInfo]];
}

@end
