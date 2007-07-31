
#import "CCMServerMonitorTest.h"
#import "CCMServerMonitor.h"
#import "CCMProject.h"


@implementation CCMServerMonitorTest

- (void)setUp
{
	info = [NSMutableDictionary dictionary];
}

- (void)testCreatesProjects
{
	[info setValue:@"connectfour" forKey:@"name"];
	[info setValue:@"Success" forKey:@"lastBuildStatus"];
	
	CCMServerMonitor *monitor = [[[CCMServerMonitor alloc] initWithConnection:(id)self] autorelease];
	[monitor pollServer:nil];
	
	NSArray *projectList = [monitor projects];
	
	STAssertEquals(1u, [projectList count], @"Should have created one project.");
	CCMProject *project = [projectList objectAtIndex:0];
	STAssertEqualObjects(@"connectfour", [project name], @"Should have set up project with right name."); 
	STAssertEqualObjects(@"Success", [project valueForKey:@"lastBuildStatus"], @"Should have set up project info."); 
}

- (void)testUpdatesProjects
{
	CCMServerMonitor *monitor = [[[CCMServerMonitor alloc] initWithConnection:(id)self] autorelease];

	[info setValue:@"connectfour" forKey:@"name"];
	[info setValue:@"Success" forKey:@"lastBuildStatus"];
	[monitor pollServer:nil];

	[info setValue:@"connectfour" forKey:@"name"];
	[info setValue:@"Failure" forKey:@"lastBuildStatus"];
	[monitor pollServer:nil];
	
	NSArray *projectList = [monitor projects];
	
	STAssertEquals(1u, [projectList count], @"Should have created only one project.");
	CCMProject *project = [projectList objectAtIndex:0];
	STAssertEqualObjects(@"Failure", [project valueForKey:@"lastBuildStatus"], @"Should have updated project info."); 
}

// connection stub

- (NSArray *)getProjectInfos
{
	return [NSArray arrayWithObject:info];
}

@end
