
#import "CCMStatusBarMenuControllerTest.h"
#import "CCMStatusBarMenuController.h"
#import "CCMProject.h"

@implementation CCMStatusBarMenuControllerTest

- (void)setUp
{
    NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"Test"] autorelease];
	NSMenuItem *projectItem = [[[NSMenuItem alloc] initWithTitle:@"(loading...)" action:NULL keyEquivalent:@""] autorelease];
	[menu addItem:projectItem];
	[menu addItem:[NSMenuItem separatorItem]];
	NSMenuItem *openItem = [[[NSMenuItem alloc] initWithTitle:@"Open..." action:NULL keyEquivalent:@""] autorelease];
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
	
	[controller displayProjects:infoList];
	
	NSArray *items = [[statusItem menu] itemArray];
	STAssertEqualObjects(@"connectfour", [[items objectAtIndex:0] title], @"Should have set right project name.");
	STAssertEquals(controller, [[items objectAtIndex:0] target], @"Should have set right target.");
	STAssertTrue([[items objectAtIndex:1] isSeparatorItem], @"Should have separator after projects.");
	STAssertEquals(3u, [items count], @"Should have created right number of items.");
}

- (void)testDisplaysSuccessWhenAllProjectsSuccessful
{
	CCMProject *project = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	NSArray *infoList = [NSArray arrayWithObject:project];
	
	[controller displayProjects:infoList];
	
	NSString *expected = [NSString stringWithFormat:@"%@-%@", CCMSleepingActivity, CCMSuccessStatus];
	STAssertEqualObjects(expected, [[statusItem image] name], @"Should have set right image.");
}

- (void)testDisplaysFailureWhenNotAllProjectsSuccessful
{
	CCMProject *project1 = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	CCMProject *project2 = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	CCMProject *project3 = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	NSArray *infoList = [NSArray arrayWithObjects:project1, project2, project3, nil];
	
	[controller displayProjects:infoList];
	
	NSString *expected = [NSString stringWithFormat:@"%@-%@", CCMSleepingActivity, CCMFailedStatus];
	STAssertEqualObjects(expected, [[statusItem image] name], @"Should have set right image.");
	STAssertEqualObjects(@"2", [statusItem title], @"Should have added title with number of failed projects.");
}

- (void)testDisplaysBuildingWhenProjectIsBuilding
{
	CCMProject *project1 = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	CCMProject *project2 = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	CCMProject *project3 = [self createProjectWithActivity:CCMBuildingActivity lastBuildStatus:CCMSuccessStatus];
	NSArray *infoList = [NSArray arrayWithObjects:project1, project2, project3, nil];
	
	[controller displayProjects:infoList];
	
	NSString *expected = [NSString stringWithFormat:@"%@-%@", CCMBuildingActivity, CCMSuccessStatus];
	STAssertEqualObjects(expected, [[statusItem image] name], @"Should have set right image.");
	STAssertEqualObjects(@"", [statusItem title], @"Should not have set title.");
}

- (void)testDisplaysFixingWhenProjectIsBuildingWithLastStatusFailed
{
	CCMProject *project1 = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMSuccessStatus];
	CCMProject *project2 = [self createProjectWithActivity:CCMSleepingActivity lastBuildStatus:CCMFailedStatus];
	CCMProject *project3 = [self createProjectWithActivity:CCMBuildingActivity lastBuildStatus:CCMFailedStatus];
	NSArray *infoList = [NSArray arrayWithObjects:project1, project2, project3, nil];
	
	[controller displayProjects:infoList];
	
	NSString *expected = [NSString stringWithFormat:@"%@-%@", CCMBuildingActivity, CCMFailedStatus];
	STAssertEqualObjects(expected, [[statusItem image] name], @"Should have set right image.");
	STAssertEqualObjects(@"", [statusItem title], @"Should not have set title.");
}


// stub image factory

- (NSImage *)imageForUnavailableServer
{
	return [[[NSImage alloc] init] autorelease];
}

- (NSImage *)imageForActivity:(NSString *)activity lastBuildStatus:(NSString *)lastBuildStatus
{
	NSString *name = [NSString stringWithFormat:@"%@-%@", activity, lastBuildStatus];
	NSImage *image = [NSImage imageNamed:name];
	if(image == nil)
	{
		image = [[[NSImage alloc] init] autorelease];
		[image setName:name];
	}
	return image;
}

- (NSImage *)convertForMenuUse:(NSImage *)image
{
	return image;
}

@end
