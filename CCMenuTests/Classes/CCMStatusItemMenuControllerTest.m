
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

- (void)testAddsProjects
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
                         [self createProjectWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus], nil];
    [[projects objectAtIndex:1] setBuildDuration:[NSNumber numberWithInt:300]];
    [[projects objectAtIndex:2] setBuildDuration:[NSNumber numberWithInt:30]];
    [[projects each] setBuildStartTime:[NSDate date]];
    [[[serverMonitorMock stub] andReturn:projects] projects];
	[[[imageFactoryMock stub] andReturn:dummyImage] imageForActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];
    
	[controller displayProjects:nil];
	
	STAssertTrue([[[controller statusItem] title] hasSuffix:@"s"], @"Should display text for project with less than a minute remaining.");
}

- (void)testDisplaysTimingForFixingEvenIfItsLongerThanForBuilding
{
    
}

@end
