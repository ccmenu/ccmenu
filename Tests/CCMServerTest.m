
#import "CCMServerTest.h"
#import "CCMProject.h"


@implementation CCMServerTest

- (void)setUp
{
	NSArray *projectNames = [NSArray arrayWithObject:@"connectfour"];
	server = [[[CCMServer alloc] initWithProjectNames:projectNames] autorelease];	
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
	NSArray *projectList = [server projects];
	
	STAssertEquals(1u, [projectList count], @"Should have created one project.");
	CCMProject *project = [projectList objectAtIndex:0];
	STAssertEqualObjects(@"connectfour", [project name], @"Should have set up project with right name."); 
}

- (void)testUpdatesProjects
{
	[server updateWithProjectInfo:[self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus]];
	[server updateWithProjectInfo:[self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus]];
	
	NSArray *projectList = [server projects];
	
	STAssertEquals(1u, [projectList count], @"Should have created only one project.");
	CCMProject *project = [projectList objectAtIndex:0];
	STAssertEqualObjects(CCMFailedStatus, [project lastBuildStatus], @"Should have updated project projectInfo."); 
}

- (void)testIgnoresProjectsNotInInitialList
{	
	NSDictionary *pi1 = [self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	[server updateWithProjectInfo:pi1];
	NSMutableDictionary *pi2 = [[self createProjectInfoWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus] mutableCopy];
	[pi2 setObject:@"foo" forKey:@"name"];
	[server updateWithProjectInfo:pi2];
	
	NSArray *projectList = [server projects];
	
	STAssertEquals(1u, [projectList count], @"Should have ignored additional project.");
	CCMProject *project = [projectList objectAtIndex:0];
	STAssertEqualObjects(@"connectfour", [project name], @"Should have kept project with right name."); 
	STAssertEqualObjects(CCMSuccessStatus, [project lastBuildStatus], @"Should have updated project projectInfo."); 
}

@end
