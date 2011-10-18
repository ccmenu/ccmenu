
#import "NSArray+CCMAdditions.h"
#import "CCMStatusItemMenuControllerTest.h"
#import "CCMProject.h"


@implementation CCMStatusItemMenuControllerTest

- (void)setUp
{
	controller = [[[CCMStatusItemMenuController alloc] init] autorelease];

    serverMonitorMock = [OCMockObject mockForClass:[CCMServerMonitor class]];
	[controller setValue:serverMonitorMock forKey:@"serverMonitor"];

	imageFactoryMock = [OCMockObject niceMockForClass:[CCMImageFactory class]];
	[controller setValue:imageFactoryMock forKey:@"imageFactory"];
    
    NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"Test"] autorelease];
	[menu addItem:[[[NSMenuItem alloc] initWithTitle:@"test project" action:NULL keyEquivalent:@""] autorelease]];
	[menu addItem:[NSMenuItem separatorItem]];    
	[controller setValue:menu forKey:@"statusMenu"];
	
    [controller awakeFromNib];
	
	dummyImage = [[[NSImage alloc] init] autorelease];
}

- (CCMProject *)createProjectWithActivity:(NSString *)activity lastBuildStatus:(NSString *)status
{
	CCMProject *project = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:activity forKey:@"activity"];
	[info setObject:status forKey:@"lastBuildStatus"];
	[info setObject:[NSCalendarDate calendarDate] forKey:@"lastBuildDate"];
    [project setStatus:[[[CCMProjectStatus alloc] initWithDictionary:info] autorelease]];
	return project;
}

- (void)testCreatesMenuItem
{
    NSArray *projects = [NSArray arrayWithObject:   
                         [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus]];
    [[[serverMonitorMock stub] andReturn:projects] projects];
	
	[controller displayProjects:nil];
	
	NSArray *items = [[[controller statusItem] menu] itemArray];
	STAssertEqualObjects(@"connectfour", [[items objectAtIndex:0] title], @"Should have set correct project name.");
	STAssertEquals(controller, [[items objectAtIndex:0] target], @"Should have set correct target.");
	STAssertTrue([[items objectAtIndex:1] isSeparatorItem], @"Should have separator after projects.");
	STAssertEquals(2u, [items count], @"Menu should have correct number of items.");
}

- (void)testAddsMenuItemInAlphabeticalOrder
{
    NSMutableArray *projects = [NSMutableArray arrayWithObject:   
                         [[[CCMProject alloc] initWithName:@"xyz"] autorelease]];
    [[[serverMonitorMock stub] andReturn:projects] projects];
	[controller displayProjects:nil];
    [projects addObject:[[[CCMProject alloc] initWithName:@"abc"] autorelease]];
    [controller displayProjects:nil];

	NSArray *items = [[[controller statusItem] menu] itemArray];
	STAssertEqualObjects(@"abc", [[items objectAtIndex:0] title], @"Should have ordered projects alphabetically.");
	STAssertEqualObjects(@"xyz", [[items objectAtIndex:1] title], @"Should have ordered projects alphabetically.");
	STAssertEquals(3u, [items count], @"Menu should have correct number of items.");
}

- (void)testRemovesMenuItem
{
    NSMutableArray *projects = [NSMutableArray arrayWithObjects:   
                                [[[CCMProject alloc] initWithName:@"xyz"] autorelease],
                                [[[CCMProject alloc] initWithName:@"abc"] autorelease], nil];
    [[[serverMonitorMock stub] andReturn:projects] projects];
	[controller displayProjects:nil];
    [projects removeObjectAtIndex:0];
    [controller displayProjects:nil];
    
	NSArray *items = [[[controller statusItem] menu] itemArray];
	STAssertEqualObjects(@"abc", [[items objectAtIndex:0] title], @"Should have kept correct project.");
	STAssertTrue([[items objectAtIndex:1] isSeparatorItem], @"Should have separator after projects.");
	STAssertEquals(2u, [items count], @"Menu should have correct number of items.");
}

- (void)testUpdatesMenuItemsForProjectsWithSameNameOnDifferentServers
{
    CCMProject *p1 = [[[CCMProject alloc] initWithName:@"bar"] autorelease];
    [p1 setServerURL:[NSURL URLWithString:@"http://server1"]];
    CCMProject *p2 = [[[CCMProject alloc] initWithName:@"bar"] autorelease];
    [p1 setServerURL:[NSURL URLWithString:@"http://server2"]];
    CCMProject *p3 = [[[CCMProject alloc] initWithName:@"foo"] autorelease];
    
    NSMutableArray *projects = [NSMutableArray array];
    [[[serverMonitorMock stub] andReturn:projects] projects];

    [projects setArray:[NSArray arrayWithObjects:p1, p2, p3, nil]];
	[controller displayProjects:nil];
    [projects setArray:[NSArray arrayWithObjects:p2, p1, nil]];
    [controller displayProjects:nil];
    
	NSArray *items = [[[controller statusItem] menu] itemArray];
	STAssertEqualObjects(@"bar", [[items objectAtIndex:0] title], @"Should have kept correct project.");
	STAssertEqualObjects(@"bar", [[items objectAtIndex:1] title], @"Should have kept correct project.");
    STAssertTrue([[items objectAtIndex:0] representedObject] != [[items objectAtIndex:1] representedObject], @"Should have different projects in menu.");
	STAssertTrue([[items objectAtIndex:2] isSeparatorItem], @"Should have separator after projects.");
}


- (void)testDisplaysUnknownWhenNoStatusIsKnown
{
    NSArray *projects = [NSArray arrayWithObject:   
                         [[[CCMProject alloc] initWithName:@"connectfour"] autorelease]];
    [[[serverMonitorMock stub] andReturn:projects] projects];
	[[[imageFactoryMock stub] andReturn:dummyImage] imageForActivity:nil lastBuildStatus:nil];
	
	[controller displayProjects:nil];
	
	STAssertEqualObjects(dummyImage, [[controller statusItem] image], @"Should display correct image.");
	STAssertEqualObjects(@"", [[controller statusItem] title], @"Should display no text.");
}

- (void)testDisplaysSuccessAndNoTextWhenAllProjectsWithStatusAreSleepingAndSuccessful
{
    NSArray *projects = [NSArray arrayWithObjects:   
                         [[[CCMProject alloc] initWithName:@"connectfour"] autorelease],
                         [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus], nil];
    [[[serverMonitorMock stub] andReturn:projects] projects];
	[[[imageFactoryMock stub] andReturn:dummyImage] imageForActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	
	[controller displayProjects:nil];
	
	STAssertEqualObjects(dummyImage, [[controller statusItem] image], @"Should display correct image.");
	STAssertEqualObjects(@"", [[controller statusItem] title], @"Should display no text.");
}

- (void)testDisplaysFailureAndNumberOfFailuresWhenAllAreSleepingAndAtLeastOneIsFailed
{
    NSArray *projects = [NSArray arrayWithObjects:   
                         [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus],
                         [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus],
                         [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus], nil];
    [[[serverMonitorMock stub] andReturn:projects] projects];
	[[[imageFactoryMock stub] andReturn:dummyImage] imageForActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	
	[controller displayProjects:nil];
	
	STAssertEqualObjects(dummyImage, [[controller statusItem] image], @"Should display correct image.");
	STAssertEqualObjects(@"2", [[controller statusItem] title], @"Should display correct number.");
}

- (void)testDisplaysBuildingWhenAtLeastOneProjectIsBuilding
{
    NSArray *projects = [NSArray arrayWithObjects:   
                         [self createProjectWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus],
                         [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus],
                         [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus], nil];
    [[[serverMonitorMock stub] andReturn:projects] projects];
	[[[imageFactoryMock stub] andReturn:dummyImage] imageForActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus];
	
	[controller displayProjects:nil];
	
	STAssertEqualObjects(dummyImage, [[controller statusItem] image], @"Should display correct image.");
	STAssertEqualObjects(@"", [[controller statusItem] title], @"Should display no text.");
}

- (void)testDisplaysFixingWhenAtLeastOneProjectWithLastStatusFailedIsBuilding
{
    NSArray *projects = [NSArray arrayWithObjects:   
                         [self createProjectWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus],
                         [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus],
                         [self createProjectWithActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus], nil];
    [[[serverMonitorMock stub] andReturn:projects] projects];
	[[[imageFactoryMock stub] andReturn:dummyImage] imageForActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];

	[controller displayProjects:nil];
	
	STAssertEqualObjects(dummyImage, [[controller statusItem] image], @"Should display correct image.");
	STAssertEqualObjects(@"", [[controller statusItem] title], @"Should display no text.");
}

- (void)testDisplaysShortestTimingForBuildingProjectsWithEstimatedCompleteTime
{
    NSArray *projects = [NSArray arrayWithObjects:   
                         [self createProjectWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus],
                         [self createProjectWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus],
                         [self createProjectWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus],
                         [self createProjectWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus], nil];
    [[projects objectAtIndex:1] setBuildDuration:[NSNumber numberWithInt:90]];
    [[projects objectAtIndex:2] setBuildDuration:[NSNumber numberWithInt:30]];
    [[projects objectAtIndex:3] setBuildDuration:[NSNumber numberWithInt:70]];
    [[projects each] setBuildStartTime:[NSDate date]];
    [[[serverMonitorMock stub] andReturn:projects] projects];
	[[[imageFactoryMock stub] andReturn:dummyImage] imageForActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];
    
	[controller displayProjects:nil];
	
	STAssertTrue([[[controller statusItem] title] hasSuffix:@"s"], @"Should display text for project with less than a minute remaining.");
}

- (void)testDisplaysTimingForFixingEvenIfItsLongerThanForBuilding
{
    NSArray *projects = [NSArray arrayWithObjects:   
                         [self createProjectWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus],
                         [self createProjectWithActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus],
                         [self createProjectWithActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus],
                         [self createProjectWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus], nil];
    [[projects objectAtIndex:1] setBuildDuration:[NSNumber numberWithInt:90]];
    [[projects objectAtIndex:2] setBuildDuration:[NSNumber numberWithInt:90]];
    [[projects objectAtIndex:3] setBuildDuration:[NSNumber numberWithInt:30]];
    [[projects each] setBuildStartTime:[NSDate date]];
    [[[serverMonitorMock stub] andReturn:projects] projects];
	[[[imageFactoryMock stub] andReturn:dummyImage] imageForActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];
    
	[controller displayProjects:nil];
	
	STAssertTrue([[[controller statusItem] title] hasPrefix:@"-1:"], @"Should display text for project with more than a minute remaining.");
    
}

@end
