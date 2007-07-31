
#import "CCMStatusBarMenuControllerTest.h"
#import "CCMStatusBarMenuController.h"
#import "CCMProject.h"

@implementation CCMStatusBarMenuControllerTest

static NSImage *testImage;

- (void)setUp
{
    menu = [[[NSMenu alloc] initWithTitle:@"Test"] autorelease];
	NSMenuItem *sepItem = [[[NSMenuItem separatorItem] copy] autorelease];
	[sepItem setTag:7];
	[menu addItem:sepItem];
	[menu addItem:[NSMenuItem separatorItem]];
	NSMenuItem *openItem = [[[NSMenuItem alloc] initWithTitle:@"Open..." action:NULL keyEquivalent:@""] autorelease];
	[openItem setTag:8];
	[openItem setTarget:self];
	[menu addItem:openItem];
}

- (void)testAddsProjects
{
	CCMProject *project = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:CCMFailedStatus forKey:@"lastBuildStatus"];
	[info setObject:[NSCalendarDate calendarDate] forKey:@"lastBuildDate"];
	[project updateWithInfo:info];
	NSArray *infoList = [NSArray arrayWithObject:project];
	
	CCMStatusBarMenuController *controller = [[[CCMStatusBarMenuController alloc] init] autorelease];
	[controller setMenu:menu];
	[controller setImageFactory:(id)self];
	testImage = [[[NSImage alloc] init] autorelease];
	NSStatusItem *statusItem = [controller createStatusItem];
	[controller displayProjectInfos:infoList];
	
	STAssertNotNil([statusItem image], @"Should have set an image.");
	STAssertEqualObjects(testImage, [statusItem image], @"Should have set right image.");
	STAssertEqualObjects(@"1", [statusItem title], @"Should have added title with number of failed projects.");
	
	NSArray *items = [[statusItem menu] itemArray];
	STAssertEqualObjects(@"connectfour", [[items objectAtIndex:1] title], @"Should have set right project name.");
	STAssertEquals(controller, [[items objectAtIndex:1] target], @"Should have set right target.");
	STAssertTrue([[items objectAtIndex:2] isSeparatorItem], @"Should have separator after projects.");
	STAssertEquals(4u, [items count], @"Should have created right number of items.");
}


// stub image factory

- (NSImage *)getImageForStatus:(NSString *)name
{
	return testImage;
}

@end
