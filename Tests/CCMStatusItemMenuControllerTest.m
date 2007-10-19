
#import "CCMStatusItemMenuControllerTest.h"
#import "CCMProject.h"


@implementation CCMStatusItemMenuControllerTest

- (void)setUp
{
    NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"Test"] autorelease];
	NSMenuItem *projectItem = [[[NSMenuItem alloc] initWithTitle:@"(loading...)" action:NULL keyEquivalent:@""] autorelease];
	[menu addItem:projectItem];
	[menu addItem:[NSMenuItem separatorItem]];
	NSMenuItem *openItem = [[[NSMenuItem alloc] initWithTitle:@"Open..." action:NULL keyEquivalent:@""] autorelease];
	[openItem setTarget:self];
	[menu addItem:openItem];

	imageFactoryMock = [OCMockObject niceMockForClass:[CCMImageFactory class]];
	controller = [[[CCMStatusItemMenuController alloc] init] autorelease];
	[controller setMenu:menu];
	[controller setImageFactory:(id)imageFactoryMock];
	statusItem = [controller createStatusItem];
	
	testImage = [[[NSImage alloc] init] autorelease];
}

- (CCMProject *)createProjectWithActivity:(NSString *)activity lastBuildStatus:(NSString *)status
{
	CCMProject *project = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:activity forKey:@"activity"];
	[info setObject:status forKey:@"lastBuildStatus"];
	[info setObject:[NSCalendarDate calendarDate] forKey:@"lastBuildDate"];
	[project updateWithInfo:info];
	return project;
}

- (void)testAddsProjects
{
	CCMProject *project = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	NSArray *projectList = [NSArray arrayWithObject:project];
	
	[controller displayProjects:projectList];
	
	NSArray *items = [[statusItem menu] itemArray];
	STAssertEqualObjects(@"connectfour", [[items objectAtIndex:0] title], @"Should have set right project name.");
	STAssertEquals(controller, [[items objectAtIndex:0] target], @"Should have set right target.");
	STAssertTrue([[items objectAtIndex:1] isSeparatorItem], @"Should have separator after projects.");
	STAssertEquals(3u, [items count], @"Should have created right number of items.");
}

- (void)testDisplaysSuccessWhenAllProjectsSuccessful
{
	CCMProject *project = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	NSArray *projectList = [NSArray arrayWithObject:project];
	[[[imageFactoryMock stub] andReturn:testImage] imageForActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	
	[controller displayProjects:projectList];
	
	STAssertEqualObjects(testImage, [statusItem image], @"Should have used right image.");
}

- (void)testDisplaysFailureWhenNotAllProjectsSuccessful
{
	CCMProject *project1 = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	CCMProject *project2 = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	CCMProject *project3 = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	NSArray *projectList = [NSArray arrayWithObjects:project1, project2, project3, nil];
	[[[imageFactoryMock stub] andReturn:testImage] imageForActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	
	[controller displayProjects:projectList];
	
	STAssertEqualObjects(testImage, [statusItem image], @"Should have used right image.");
}

- (void)testDisplaysBuildingWhenProjectIsBuilding
{
	CCMProject *project1 = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	CCMProject *project2 = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	CCMProject *project3 = [self createProjectWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus];
	NSArray *projectList = [NSArray arrayWithObjects:project1, project2, project3, nil];
	[[[imageFactoryMock stub] andReturn:testImage] imageForActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus];
	
	[controller displayProjects:projectList];
	
	STAssertEqualObjects(testImage, [statusItem image], @"Should have used right image.");
}

- (void)testDisplaysFixingWhenProjectIsBuildingWithLastStatusFailed
{
	CCMProject *project1 = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	CCMProject *project2 = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	CCMProject *project3 = [self createProjectWithActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];
	NSArray *projectList = [NSArray arrayWithObjects:project1, project2, project3, nil];
	[[[imageFactoryMock stub] andReturn:testImage] imageForActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];

	[controller displayProjects:projectList];
	
	STAssertEqualObjects(testImage, [statusItem image], @"Should have used right image.");
}

- (void)testDisplaysUnknownWhenNoStatusIsKnown
{
	CCMProject *project = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
	NSArray *projectList = [NSArray arrayWithObjects:project, nil];
	[[[imageFactoryMock stub] andReturn:testImage] imageForActivity:nil lastBuildStatus:nil];
	
	[controller displayProjects:projectList];
	
	STAssertEqualObjects(testImage, [statusItem image], @"Should have used right image.");
}


@end
