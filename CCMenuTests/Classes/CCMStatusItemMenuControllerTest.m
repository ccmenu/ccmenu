#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "NSArray+CCMAdditions.h"
#import "CCMStatusItemMenuController.h"


@interface NSStatusItem(MyTitleFormatting)

- (void)setFormattedTitle:(NSString *)aTitle;

@end


@interface CCMStatusItemMenuControllerTest : XCTestCase
{
	CCMStatusItemMenuController	*controller;
	NSImage						*dummyImage;

    id                          serverMonitorMock;
    id                          imageFactoryMock;
    id                          statusItemMock;
}

@end

@implementation CCMStatusItemMenuControllerTest

- (void)setUp
{
	controller = [[[CCMStatusItemMenuController alloc] init] autorelease];

    serverMonitorMock = OCMClassMock([CCMServerMonitor class]);
	[controller setValue:serverMonitorMock forKey:@"serverMonitor"];

	imageFactoryMock = OCMClassMock([CCMImageFactory class]);
	[controller setValue:imageFactoryMock forKey:@"imageFactory"];
    
    statusItemMock = OCMClassMock([NSStatusItem class]);
    [controller setValue:statusItemMock forKey:@"statusItem"];

    NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"Test"] autorelease];
	[menu addItem:[[[NSMenuItem alloc] initWithTitle:@"test project" action:NULL keyEquivalent:@""] autorelease]];
	[menu addItem:[NSMenuItem separatorItem]];
	[controller setValue:menu forKey:@"statusMenu"];
    OCMStub([statusItemMock menu]).andReturn(menu);

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
    NSArray *projects = @[[self createProjectWithActivity:@"Sleeping" lastBuildStatus:@"Failure"]];
    [[[serverMonitorMock stub] andReturn:projects] projects];
	
	[controller displayProjects:nil];
	
	NSArray *items = [[[controller statusItem] menu] itemArray];
	XCTAssertEqualObjects(@"connectfour", [[items objectAtIndex:0] title], @"Should have set correct project name.");
	XCTAssertEqual(controller, [[items objectAtIndex:0] target], @"Should have set correct target.");
	XCTAssertTrue([[items objectAtIndex:1] isSeparatorItem], @"Should have separator after projects.");
	XCTAssertEqual(2ul, [items count], @"Menu should have correct number of items.");
}

- (void)testAddsMenuItemsInAlphabeticalOrder
{
    id defaultsMock = OCMClassMock([CCMUserDefaultsManager class]);
    OCMStub([defaultsMock projectOrder]).andReturn(CCMProjectOrderAlphabetic) ;
    [controller setValue:defaultsMock forKey:@"defaultsManager"];

    NSMutableArray *projects = [@[[[[CCMProject alloc] initWithName:@"xyz"] autorelease]] mutableCopy];
    OCMStub([serverMonitorMock projects]).andReturn(projects);
	[controller displayProjects:nil];
    [projects addObject:[[[CCMProject alloc] initWithName:@"abc"] autorelease]];
    [controller displayProjects:nil];

	NSArray *items = [[[controller statusItem] menu] itemArray];
	XCTAssertEqualObjects(@"abc", [[items objectAtIndex:0] title], @"Should have ordered projects alphabetically.");
	XCTAssertEqualObjects(@"xyz", [[items objectAtIndex:1] title], @"Should have ordered projects alphabetically.");
	XCTAssertEqual(3ul, [items count], @"Menu should have correct number of items.");
}

- (void)testSortsMenuItemsByBuildTime
{
    id defaultsMock = OCMClassMock([CCMUserDefaultsManager class]);
    OCMStub([defaultsMock projectOrder]).andReturn(CCMProjectOrderByBuildTime) ;
    [controller setValue:defaultsMock forKey:@"defaultsManager"];

    CCMProject *p1 = [[[CCMProject alloc] initWithName:@"abc"] autorelease];
    [p1 updateWithInfo:@{@"lastBuildTime": [[NSCalendarDate calendarDate] dateByAddingTimeInterval:-90]}];
    CCMProject *p2 = [[[CCMProject alloc] initWithName:@"xyz"] autorelease];
    [p2 updateWithInfo:@{@"lastBuildTime": [[NSCalendarDate calendarDate] dateByAddingTimeInterval:-10]}];
    NSArray *const projects = @[p1, p2];
    OCMStub([serverMonitorMock projects]).andReturn(projects);
                 
    [controller displayProjects:nil];
    
	NSArray *items = [[[controller statusItem] menu] itemArray];
	XCTAssertEqualObjects(@"xyz", [[items objectAtIndex:0] title], @"Should have ordered projects by build time.");
	XCTAssertEqualObjects(@"abc", [[items objectAtIndex:1] title], @"Should have ordered projects by build time.");
	XCTAssertEqual(3ul, [items count], @"Menu should have correct number of items.");
}

- (void)testKeepsMenuItemsInNaturalOrder
{
    id defaultsMock = OCMClassMock([CCMUserDefaultsManager class]);
    OCMStub([defaultsMock projectOrder]).andReturn(CCMProjectOrderNatural) ;
    [controller setValue:defaultsMock forKey:@"defaultsManager"];

    CCMProject *p1 = [[[CCMProject alloc] initWithName:@"xyz"] autorelease];
    [p1 updateWithInfo:@{@"lastBuildTime": [[NSCalendarDate calendarDate] dateByAddingTimeInterval:-90]}];
    CCMProject *p2 = [[[CCMProject alloc] initWithName:@"abc"] autorelease];
    [p2 updateWithInfo:@{@"lastBuildTime": [[NSCalendarDate calendarDate] dateByAddingTimeInterval:-10]}];
    NSArray *const projects = @[p1, p2];
    OCMStub([serverMonitorMock projects]).andReturn(projects);

    [controller displayProjects:nil];

	NSArray *items = [[[controller statusItem] menu] itemArray];
	XCTAssertEqualObjects(@"xyz", [[items objectAtIndex:0] title], @"Should have ordered projects as added.");
	XCTAssertEqualObjects(@"abc", [[items objectAtIndex:1] title], @"Should have ordered projects as added.");
	XCTAssertEqual(3ul, [items count], @"Menu should have correct number of items.");
}

- (void)testRemovesMenuItem
{
    NSMutableArray *projects = [@[[[[CCMProject alloc] initWithName:@"xyz"] autorelease],
                                  [[[CCMProject alloc] initWithName:@"abc"] autorelease]]
                                mutableCopy];
    OCMStub([serverMonitorMock projects]).andReturn(projects);
	[controller displayProjects:nil];
    [projects removeObjectAtIndex:0];
    [controller displayProjects:nil];
    
	NSArray *items = [[[controller statusItem] menu] itemArray];
	XCTAssertEqualObjects(@"abc", [[items objectAtIndex:0] title], @"Should have kept correct project.");
	XCTAssertTrue([[items objectAtIndex:1] isSeparatorItem], @"Should have separator after projects.");
	XCTAssertEqual(2ul, [items count], @"Menu should have correct number of items.");
}

- (void)testUpdatesMenuItemsForProjectsWithSameNameOnDifferentServers
{
    CCMProject *p1 = [[[CCMProject alloc] initWithName:@"bar"] autorelease];
    [p1 setServerURL:[NSURL URLWithString:@"http://server1"]];
    CCMProject *p2 = [[[CCMProject alloc] initWithName:@"bar"] autorelease];
    [p1 setServerURL:[NSURL URLWithString:@"http://server2"]];
    CCMProject *p3 = [[[CCMProject alloc] initWithName:@"foo"] autorelease];
    
    NSMutableArray *projects = [NSMutableArray array];
    OCMStub([serverMonitorMock projects]).andReturn(projects);

    [projects setArray:@[p1, p2, p3]];
	[controller displayProjects:nil];
    [projects setArray:@[p2, p1]];
    [controller displayProjects:nil];
    
	NSArray *items = [[[controller statusItem] menu] itemArray];
	XCTAssertEqualObjects(@"bar", [[items objectAtIndex:0] title], @"Should have kept correct project.");
	XCTAssertEqualObjects(@"bar", [[items objectAtIndex:1] title], @"Should have kept correct project.");
    XCTAssertTrue([[items objectAtIndex:0] representedObject] != [[items objectAtIndex:1] representedObject], @"Should have different projects in menu.");
	XCTAssertTrue([[items objectAtIndex:2] isSeparatorItem], @"Should have separator after projects.");
}

-(void)testDisplaysLastBuildTimes
{
    id defaultsMock = OCMClassMock([CCMUserDefaultsManager class]);
    OCMStub([defaultsMock projectOrder]).andReturn(CCMProjectOrderNatural);
    OCMStub([defaultsMock shouldShowLastBuildTimes]).andReturn(YES);
    [controller setValue:defaultsMock forKey:@"defaultsManager"];

    id dateMock = OCMClassMock([NSCalendarDate class]);
    NSTimeInterval interval = [[NSCalendarDate date] timeIntervalSinceReferenceDate] - 61;
    OCMStub([dateMock timeIntervalSinceReferenceDate]).andReturn(interval);
    
    CCMProject *p1 = [[[CCMProject alloc] initWithName:@"foo"] autorelease];
    [p1 updateWithInfo:@{@"lastBuildTime": dateMock}];
    CCMProject *p2 = [[[CCMProject alloc] initWithName:@"bar"] autorelease];
    NSArray *const projects = @[p1, p2];
    OCMStub([serverMonitorMock projects]).andReturn(projects);
    
    [controller displayProjects:nil];
    
	NSArray *items = [[[controller statusItem] menu] itemArray];
	XCTAssertEqualObjects(@"foo \u2014 a minute ago", [[items objectAtIndex:0] title], @"Should have included last build time where known.");
	XCTAssertEqualObjects(@"bar", [[items objectAtIndex:1] title], @"Should have shown just name when last build time is not known.");
}


- (void)testDisplaysUnknownWhenNoStatusIsKnown
{
    CCMProject *p1 = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
    OCMStub([serverMonitorMock projects]).andReturn(@[p1]);
    OCMStub([imageFactoryMock imageForUnavailableServer]).andReturn(dummyImage);
    OCMStub([imageFactoryMock convertForItemUse:dummyImage]).andReturn(dummyImage);

	[controller displayProjects:nil];
	
    OCMVerify([statusItemMock setImage:dummyImage]);
    OCMVerify([statusItemMock setTitle:@""]);
}

- (void)testDisplaysSuccessAndNoTextWhenAllProjectsWithStatusAreSleepingAndSuccessful
{
    CCMProject *p1 = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
    CCMProject *p2 = [self createProjectWithActivity:@"Sleeping" lastBuildStatus:@"Success"];
    NSArray *const projects = @[p1, p2];
    OCMStub([serverMonitorMock projects]).andReturn(projects);
    OCMStub([imageFactoryMock imageForStatus:[p2 status]]).andReturn(dummyImage);
    OCMStub([imageFactoryMock convertForItemUse:dummyImage]).andReturn(dummyImage);
	
	[controller displayProjects:nil];
	
    OCMVerify([statusItemMock setImage:dummyImage]);
    OCMVerify([statusItemMock setFormattedTitle:@""]);
}

- (void)testDisplaysFailureAndNumberOfFailuresWhenAllAreSleepingAndAtLeastOneIsFailed
{
    CCMProject *p1 = [self createProjectWithActivity:@"Sleeping" lastBuildStatus:@"Success"];
    CCMProject *p2 = [self createProjectWithActivity:@"Sleeping" lastBuildStatus:@"Failure"];
    CCMProject *p3 = [self createProjectWithActivity:@"Sleeping" lastBuildStatus:@"Failure"];
    NSArray *const projects = @[p1, p2, p3];
    OCMStub([serverMonitorMock projects]).andReturn(projects);
    OCMStub([imageFactoryMock imageForStatus:[p2 status]]).andReturn(dummyImage);
    OCMStub([imageFactoryMock imageForStatus:[p3 status]]).andReturn(dummyImage);
    OCMStub([imageFactoryMock convertForItemUse:dummyImage]).andReturn(dummyImage);

	[controller displayProjects:nil];
	
    OCMVerify([statusItemMock setImage:dummyImage]);
    OCMVerify([statusItemMock setFormattedTitle:@"2"]);
}

- (void)testDisplaysBuildingWhenAtLeastOneProjectIsBuilding
{
    CCMProject *p1 = [self createProjectWithActivity:@"Building" lastBuildStatus:@"Success"];
    CCMProject *p2 = [self createProjectWithActivity:@"Sleeping" lastBuildStatus:@"Failure"];
    CCMProject *p3 = [self createProjectWithActivity:@"Sleeping" lastBuildStatus:@"Failure"];
    NSArray *const projects = @[p1, p2, p3];
    OCMStub([serverMonitorMock projects]).andReturn(projects);
    OCMStub([imageFactoryMock imageForStatus:[p1 status]]).andReturn(dummyImage);
    OCMStub([imageFactoryMock convertForItemUse:dummyImage]).andReturn(dummyImage);

	[controller displayProjects:nil];

    OCMVerify([statusItemMock setImage:dummyImage]);
    OCMVerify([statusItemMock setFormattedTitle:@""]);
}

- (void)testDisplaysFixingWhenAtLeastOneProjectWithLastStatusFailedIsBuilding
{
    CCMProject *p1 = [self createProjectWithActivity:@"Building" lastBuildStatus:@"Success"];
    CCMProject *p2 = [self createProjectWithActivity:@"Sleeping" lastBuildStatus:@"Failure"];
    CCMProject *p3 = [self createProjectWithActivity:@"Building" lastBuildStatus:@"Failure"];
    NSArray *const projects = @[p1, p2, p3];
    OCMStub([serverMonitorMock projects]).andReturn(projects);
    OCMStub([imageFactoryMock imageForStatus:[p3 status]]).andReturn(dummyImage);
    OCMStub([imageFactoryMock convertForItemUse:dummyImage]).andReturn(dummyImage);

	[controller displayProjects:nil];
	
    OCMVerify([statusItemMock setImage:dummyImage]);
    OCMVerify([statusItemMock setFormattedTitle:@""]);
}

- (void)testDoesNotDisplayBuildingTimerWhenDefaultIsOff
{
    id defaultsMock = OCMClassMock([CCMUserDefaultsManager class]);
    OCMStub([defaultsMock shouldShowTimerInMenu]).andReturn(NO);
    [controller setValue:defaultsMock forKey:@"defaultsManager"];
    
    CCMProject *p1 = [self createProjectWithActivity:@"Building" lastBuildStatus:@"Success"];
    [p1 setBuildDuration:@90];
    [p1 setBuildStartTime:[NSCalendarDate date]];
    OCMStub([serverMonitorMock projects]).andReturn(@[p1]);

	[controller displayProjects:nil];
	
    OCMVerify([statusItemMock setFormattedTitle:@""]);
}

- (void)testDisplaysShortestTimingForBuildingProjectsWithEstimatedCompleteTime
{
    id defaultsMock = OCMClassMock([CCMUserDefaultsManager class]);
    OCMStub([defaultsMock shouldShowTimerInMenu]).andReturn(YES) ;
    [controller setValue:defaultsMock forKey:@"defaultsManager"];

    CCMProject *p1 = [self createProjectWithActivity:@"Building" lastBuildStatus:@"Success"];
    CCMProject *p2 = [self createProjectWithActivity:@"Building" lastBuildStatus:@"Success"];
    [p2 setBuildDuration:@90];
    CCMProject *p3 = [self createProjectWithActivity:@"Building" lastBuildStatus:@"Success"];
    [p3 setBuildDuration:@30];
    CCMProject *p4 = [self createProjectWithActivity:@"Building" lastBuildStatus:@"Success"];
    [p4 setBuildDuration:@70];
    NSArray *const projects = @[p1, p2, p3, p4];
    [[projects each] setBuildStartTime:[NSCalendarDate date]];
    OCMStub([serverMonitorMock projects]).andReturn(projects);

	[controller displayProjects:nil];

//  TODO: decide on hamcrest use
//	XCTAssertTrue([[[controller statusItem] title] hasSuffix:@"s"], @"Should display text for project with less than a minute remaining.");
//  OCMVerify([statusItemMock setFormattedTitle:@""]);
}

- (void)testDisplaysTimingForFixingEvenIfItsLongerThanForBuilding
{
    id defaultsMock = OCMClassMock([CCMUserDefaultsManager class]);
    OCMStub([defaultsMock shouldShowTimerInMenu]).andReturn(YES) ;
    [controller setValue:defaultsMock forKey:@"defaultsManager"];

    CCMProject *p1 = [self createProjectWithActivity:@"Building" lastBuildStatus:@"Success"];
    [p1 setBuildDuration:@30];
    CCMProject *p2 = [self createProjectWithActivity:@"Building" lastBuildStatus:@"Failure"];
    [p2 setBuildDuration:@90];
    NSArray *projects = @[p1, p2];
    [[projects each] setBuildStartTime:[NSCalendarDate date]];
    OCMStub([serverMonitorMock projects]).andReturn(projects);

	[controller displayProjects:nil];
	
//  TODO: decide on hamcrest use
//	XCTAssertTrue([[[controller statusItem] title] hasPrefix:@"-1:"], @"Should display text for project with more than a minute remaining.");
//  OCMVerify([statusItemMock setFormattedTitle:@""]);
}

@end
