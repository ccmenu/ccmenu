
#import "CCMServerMonitorTest.h"
#import "CCMProject.h"


@implementation CCMServerMonitorTest

- (void)setUp
{
	monitor = [[[CCMServerMonitor alloc] init] autorelease];
	[monitor setNotificationCenter:(id)self];
	[monitor setUserDefaults:(id)self];
	postedNotifications = [NSMutableArray array];
}

- (void)tearDown
{
	[monitor stop];
}

- (void)testCreatesRepositories
{
	NSDictionary *pd1 = [NSDictionary dictionaryWithObjectsAndKeys:@"connectfour", @"name", @"localhost", @"server", nil];
	NSDictionary *pd2 = [NSDictionary dictionaryWithObjectsAndKeys:@"cozmoz", @"name", @"another", @"server", nil];
	NSDictionary *pd3 = [NSDictionary dictionaryWithObjectsAndKeys:@"protest", @"name", @"another", @"server", nil];
	projectsUserDefaults = [NSArray arrayWithObjects:pd1, pd2, pd3, nil];
	
	[monitor start];
	
	NSArray *repositories = [monitor valueForKey:@"repositories"];
	STAssertEquals(2u, [repositories count], @"Should have created minimum number of repositories.");
}

- (void)testGetsProjectsFromRepository
{	
	// Unfortunately, we can't stub the repository because the monitor creates it. So, we need a working URL,
	// which makes this almost an integration test.
	NSString *url = [[NSURL fileURLWithPath:@"Tests/cctray.xml"] absoluteString];
	NSDictionary *pd = [NSDictionary dictionaryWithObjectsAndKeys:@"connectfour", @"name", url, @"server", nil];
	projectsUserDefaults = [NSArray arrayWithObject:pd];

	[monitor start];
	[monitor pollServers:nil];

	NSArray *projectList = [monitor projects];
	STAssertEquals(1u, [projectList count], @"Should have found one project.");
	CCMProject *project = [projectList objectAtIndex:0];
	STAssertEqualObjects(@"connectfour", [project name], @"Should have set up project with right name."); 
	STAssertEqualObjects(@"build.1", [project valueForKey:@"lastBuildLabel"], @"Should have set up project projectInfo."); 
}


// defaults stub

- (NSData *)dataForKey:(NSString *)key
{
	if([key isEqualToString:@"Projects"])
		return [NSArchiver archivedDataWithRootObject:projectsUserDefaults];
	return nil;
}

// notification center stub

- (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
	[postedNotifications addObject:[NSNotification notificationWithName:aName object:anObject userInfo:aUserInfo]];
}

@end
