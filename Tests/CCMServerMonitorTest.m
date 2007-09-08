
#import "CCMServerMonitorTest.h"
#import "CCMUserDefaultsManager.h"
#import "CCMServer.h"
#import "CCMProject.h"
#import <OCMock/OCMock.h>


@implementation CCMServerMonitorTest

- (void)setUp
{
	monitor = [[[CCMServerMonitor alloc] init] autorelease];
	[monitor setNotificationCenter:(id)self];
	defaultsManagerMock = [OCMockObject mockForClass:[CCMUserDefaultsManager class]];
	[[[defaultsManagerMock stub] andReturnValue:[NSNumber numberWithInt:1000]] pollInterval];
	[monitor setDefaultsManager:(id)defaultsManagerMock];
	postedNotifications = [NSMutableArray array];
}

- (void)tearDown
{
	[defaultsManagerMock verify];
}


- (void)testGetsProjectsFromConnection
{	
	// Unfortunately, we can't stub the connection because the repository creates it. So, we need a working URL,
	// which makes this almost an integration test.
	NSURL *url = [NSURL fileURLWithPath:@"Tests/cctray.xml"];
	CCMServer *server = [[[CCMServer alloc] initWithURL:url andProjectNames:[NSArray arrayWithObject:@"connectfour"]] autorelease];
	
	[[[defaultsManagerMock expect] andReturn:[NSArray arrayWithObject:server]] servers]; 
	
	// this is now all async and will not work in a unit test anymore
	[monitor start];
	[monitor pollServers:nil];
	
	NSArray *projectList = [monitor projects];
	STAssertEquals(1u, [projectList count], @"Should have found one project.");
	CCMProject *project = [projectList objectAtIndex:0];
	STAssertEqualObjects(@"connectfour", [project name], @"Should have set up project with right name."); 

	//	STAssertEqualObjects(@"build.1", [project lastBuildLabel], @"Should have set up project projectInfo."); 
}


// notification center stub (need this until next version of OCMock, which will have custom constraints)

- (void)addObserver:(id)notificationObserver selector:(SEL)notificationSelector name:(NSString *)notificationName object:(id)notificationSender
{	
}

- (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
	[postedNotifications addObject:[NSNotification notificationWithName:aName object:anObject userInfo:aUserInfo]];
}

@end
