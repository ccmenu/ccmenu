
#import "CCMStatusBarMenuControllerTest.h"
#import "CCMStatusBarMenuController.h"
#import "CCMProject.h"

@implementation CCMStatusBarMenuControllerTest

- (void)setUp
{
    NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"Test"] autorelease];
	NSMenuItem *sepItem = [[[NSMenuItem separatorItem] copy] autorelease];
	[sepItem setTag:7];
	[menu addItem:sepItem];
	[menu addItem:[NSMenuItem separatorItem]];
	NSMenuItem *openItem = [[[NSMenuItem alloc] initWithTitle:@"Open..." action:NULL keyEquivalent:@""] autorelease];
	[openItem setTag:8];
	[openItem setTarget:self];
	[menu addItem:openItem];

	controller = [[[CCMStatusBarMenuController alloc] init] autorelease];
	[controller setMenu:menu];
	[controller setImageFactory:(id)self];

	statusItem = [controller createStatusItem];
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
	NSArray *infoList = [NSArray arrayWithObject:project];
	
	testImage = [[[NSImage alloc] init] autorelease];
	[controller displayProjects:infoList];
	
	NSArray *items = [[statusItem menu] itemArray];
	STAssertEqualObjects(@"connectfour", [[items objectAtIndex:1] title], @"Should have set right project name.");
	STAssertEquals(controller, [[items objectAtIndex:1] target], @"Should have set right target.");
	STAssertTrue([[items objectAtIndex:2] isSeparatorItem], @"Should have separator after projects.");
	STAssertEquals(4u, [items count], @"Should have created right number of items.");
}

- (void)testDisplaysSuccessWhenAllProjectsSuccessful
{
	CCMProject *project = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	NSArray *infoList = [NSArray arrayWithObject:project];
	
	testImage = [[[NSImage alloc] init] autorelease];
	[controller displayProjects:infoList];
	
	// TODO: All these are useless. Need to solve image setName: problem
	STAssertEqualObjects(testImage, [statusItem image], @"Should have set right image.");
}

- (void)testDisplaysFailureWhenNotAllProjectsSuccessful
{
	CCMProject *project1 = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	CCMProject *project2 = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	CCMProject *project3 = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	NSArray *infoList = [NSArray arrayWithObjects:project1, project2, project3, nil];
	
	testImage = [[[NSImage alloc] init] autorelease];
	[controller displayProjects:infoList];
	
	STAssertEqualObjects(testImage, [statusItem image], @"Should have set right image.");
	STAssertEqualObjects(@"2", [statusItem title], @"Should have added title with number of failed projects.");
}

- (void)testDisplaysBuildingWhenProjectIsBuilding
{
	CCMProject *project1 = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	CCMProject *project2 = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	CCMProject *project3 = [self createProjectWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus];
	NSArray *infoList = [NSArray arrayWithObjects:project1, project2, project3, nil];
	
	testImage = [[[NSImage alloc] init] autorelease];
	[controller displayProjects:infoList];
	
	STAssertEqualObjects(testImage, [statusItem image], @"Should have set right image.");
	STAssertEqualObjects(@"", [statusItem title], @"Should not have set title.");
}

- (void)testDisplaysFixingWhenProjectIsBuildingWithLastStatusFailed
{
	CCMProject *project1 = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	CCMProject *project2 = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	CCMProject *project3 = [self createProjectWithActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];
	NSArray *infoList = [NSArray arrayWithObjects:project1, project2, project3, nil];
	
	testImage = [[[NSImage alloc] init] autorelease];
	[controller displayProjects:infoList];
	
	STAssertEqualObjects(testImage, [statusItem image], @"Should have set right image.");
	STAssertEqualObjects(@"", [statusItem title], @"Should not have set title.");
}


// stub image factory

- (NSImage *)pausedImage
{
	return testImage;
}

- (NSImage *)imageForActivity:(NSString *)activity lastBuildStatus:(NSString *)lastBuildStatus
{
	return testImage;
}

- (NSImage *)convertForMenuUse:(NSImage *)image
{
	return image;
}

@end
