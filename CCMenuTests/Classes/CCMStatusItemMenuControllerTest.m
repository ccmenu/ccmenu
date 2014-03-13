#import <OCMock/OCMock.h>

#import "NSArray+CCMAdditions.h"
#import "CCMStatusItemMenuControllerTest.h"


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
                         [self createProjectWithActivity:@"Sleeping" lastBuildStatus:@"Failure"]];
    [[[serverMonitorMock stub] andReturn:projects] projects];
	
	[controller displayProjects:nil];
	
	NSArray *items = [[[controller statusItem] menu] itemArray];
	STAssertEqualObjects(@"connectfour", [[items objectAtIndex:0] title], @"Should have set correct project name.");
	STAssertEquals(controller, [[items objectAtIndex:0] target], @"Should have set correct target.");
	STAssertTrue([[items objectAtIndex:1] isSeparatorItem], @"Should have separator after projects.");
	STAssertEquals(2ul, [items count], @"Menu should have correct number of items.");
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
	STAssertEquals(3ul, [items count], @"Menu should have correct number of items.");
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
	STAssertEquals(2ul, [items count], @"Menu should have correct number of items.");
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
    CCMProject *p1 = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
    NSArray *projects = [NSArray arrayWithObject:p1];
    [[[serverMonitorMock stub] andReturn:projects] projects];
    [[[imageFactoryMock stub] andReturn:dummyImage] imageForUnavailableServer];
	
	[controller displayProjects:nil];
	
	STAssertEqualObjects(dummyImage, [[controller statusItem] image], @"Should display correct image.");
	STAssertEqualObjects(@"", [[controller statusItem] title], @"Should display no text.");
}

- (void)testDisplaysSuccessAndNoTextWhenAllProjectsWithStatusAreSleepingAndSuccessful
{
    CCMProject *p1 = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
    CCMProject *p2 = [self createProjectWithActivity:@"Sleeping" lastBuildStatus:@"Success"];
    NSArray *projects = [NSArray arrayWithObjects:p1, p2, nil];
    [[[serverMonitorMock stub] andReturn:projects] projects];
	[[[imageFactoryMock stub] andReturn:dummyImage] imageForStatus:[p2 status]];
	
	[controller displayProjects:nil];
	
	STAssertEqualObjects(dummyImage, [[controller statusItem] image], @"Should display correct image.");
	STAssertEqualObjects(@"", [[controller statusItem] title], @"Should display no text.");
}

- (void)testDisplaysFailureAndNumberOfFailuresWhenAllAreSleepingAndAtLeastOneIsFailed
{
    CCMProject *p1 = [self createProjectWithActivity:@"Sleeping" lastBuildStatus:@"Success"];
    CCMProject *p2 = [self createProjectWithActivity:@"Sleeping" lastBuildStatus:@"Failure"];
    CCMProject *p3 = [self createProjectWithActivity:@"Sleeping" lastBuildStatus:@"Failure"];
    NSArray *projects = [NSArray arrayWithObjects:p1, p2, p3, nil];
    [[[serverMonitorMock stub] andReturn:projects] projects];
    [[[imageFactoryMock stub] andReturn:dummyImage] imageForStatus:[p2 status]];
    [[[imageFactoryMock stub] andReturn:dummyImage] imageForStatus:[p3 status]];

	[controller displayProjects:nil];
	
	STAssertEqualObjects(dummyImage, [[controller statusItem] image], @"Should display correct image.");
	STAssertEqualObjects(@"2", [[controller statusItem] title], @"Should display correct number.");
}

- (void)testDisplaysBuildingWhenAtLeastOneProjectIsBuilding
{
    CCMProject *p1 = [self createProjectWithActivity:@"Building" lastBuildStatus:@"Success"];
    CCMProject *p2 = [self createProjectWithActivity:@"Sleeping" lastBuildStatus:@"Failure"];
    CCMProject *p3 = [self createProjectWithActivity:@"Sleeping" lastBuildStatus:@"Failure"];
    NSArray *projects = [NSArray arrayWithObjects:p1, p2, p3, nil];
    [[[serverMonitorMock stub] andReturn:projects] projects];
    [[[imageFactoryMock stub] andReturn:dummyImage] imageForStatus:[p1 status]];
	
	[controller displayProjects:nil];
	
	STAssertEqualObjects(dummyImage, [[controller statusItem] image], @"Should display correct image.");
	STAssertEqualObjects(@"", [[controller statusItem] title], @"Should display no text.");
}

- (void)testDisplaysFixingWhenAtLeastOneProjectWithLastStatusFailedIsBuilding
{
    CCMProject *p1 = [self createProjectWithActivity:@"Building" lastBuildStatus:@"Success"];
    CCMProject *p2 = [self createProjectWithActivity:@"Sleeping" lastBuildStatus:@"Failure"];
    CCMProject *p3 = [self createProjectWithActivity:@"Building" lastBuildStatus:@"Failure"];
    NSArray *projects = [NSArray arrayWithObjects:p1, p2, p3, nil];
    [[[serverMonitorMock stub] andReturn:projects] projects];
    [[[imageFactoryMock stub] andReturn:dummyImage] imageForStatus:[p3 status]];

	[controller displayProjects:nil];
	
	STAssertEqualObjects(dummyImage, [[controller statusItem] image], @"Should display correct image.");
	STAssertEqualObjects(@"", [[controller statusItem] title], @"Should display no text.");
}

- (void)testDoesNotDisplayBuildingTimerWhenDefaultIsOff
{
    id defaultsMock = [OCMockObject mockForClass:[CCMUserDefaultsManager class]];
    [[[defaultsMock stub] andReturnValue:@NO] shouldShowTimerInMenu];
    [controller setValue:defaultsMock forKey:@"defaultsManager"];
    
    CCMProject *p1 = [self createProjectWithActivity:@"Building" lastBuildStatus:@"Success"];
    [p1 setBuildDuration:[NSNumber numberWithInt:90]];
    [p1 setBuildStartTime:[NSCalendarDate date]];
    [[[serverMonitorMock stub] andReturn:@[p1]] projects];
    
	[controller displayProjects:nil];
	
	STAssertEqualObjects(@"", [[controller statusItem] title], @"Should display no text.");
}

- (void)testDisplaysShortestTimingForBuildingProjectsWithEstimatedCompleteTime
{
    id defaultsMock = [OCMockObject mockForClass:[CCMUserDefaultsManager class]];
    [[[defaultsMock stub] andReturnValue:@YES] shouldShowTimerInMenu];
    [controller setValue:defaultsMock forKey:@"defaultsManager"];
    
    CCMProject *p1 = [self createProjectWithActivity:@"Building" lastBuildStatus:@"Success"];
    CCMProject *p2 = [self createProjectWithActivity:@"Building" lastBuildStatus:@"Success"];
    [p2 setBuildDuration:[NSNumber numberWithInt:90]];
    CCMProject *p3 = [self createProjectWithActivity:@"Building" lastBuildStatus:@"Success"];
    [p3 setBuildDuration:[NSNumber numberWithInt:30]];
    CCMProject *p4 = [self createProjectWithActivity:@"Building" lastBuildStatus:@"Success"];
    [p4 setBuildDuration:[NSNumber numberWithInt:70]];
    NSArray *projects = [NSArray arrayWithObjects:p1, p2, p3, p4, nil];
    [[projects each] setBuildStartTime:[NSCalendarDate date]];
    [[[serverMonitorMock stub] andReturn:projects] projects];

	[controller displayProjects:nil];
	
	STAssertTrue([[[controller statusItem] title] hasSuffix:@"s"], @"Should display text for project with less than a minute remaining.");
}

- (void)testDisplaysTimingForFixingEvenIfItsLongerThanForBuilding
{
    id defaultsMock = [OCMockObject mockForClass:[CCMUserDefaultsManager class]];
    [[[defaultsMock stub] andReturnValue:@YES] shouldShowTimerInMenu];
    [controller setValue:defaultsMock forKey:@"defaultsManager"];

    CCMProject *p1 = [self createProjectWithActivity:@"Building" lastBuildStatus:@"Success"];
    [p1 setBuildDuration:[NSNumber numberWithInt:30]];
    CCMProject *p2 = [self createProjectWithActivity:@"Building" lastBuildStatus:@"Failure"];
    [p2 setBuildDuration:[NSNumber numberWithInt:90]];
    NSArray *projects = [NSArray arrayWithObjects:p1, p2, nil];
    [[projects each] setBuildStartTime:[NSCalendarDate date]];
    [[[serverMonitorMock stub] andReturn:projects] projects];

	[controller displayProjects:nil];
	
	STAssertTrue([[[controller statusItem] title] hasPrefix:@"-1:"], @"Should display text for project with more than a minute remaining.");
    
}

@end
