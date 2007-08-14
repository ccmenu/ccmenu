
#import "CCMPreferencesControllerTest.h"
#import "CCMPreferencesController.h"
#import <OCMock/OCMock.h>


@implementation CCMPreferencesControllerTest

- (void)setUp
{
	controller = [[[CCMPreferencesController alloc] init] autorelease];
	[controller setValue:self forKey:@"userDefaults"];
	
	OCMockObject *comboBoxMock = [OCMockObject mockForClass:[NSComboBox class]];
	[[[comboBoxMock stub] andReturn:@"http://test"] stringValue];
	[controller setValue:comboBoxMock forKey:@"serverUrlComboBox"];
	
	OCMockObject *serverTypeMatrixMock = [OCMockObject mockForClass:[NSMatrix class]];
	[[[serverTypeMatrixMock stub] andReturn:0] selectedTag]; // this tag signals 'cctray.xml'
	[controller setValue:serverTypeMatrixMock forKey:@"serverTypeMatrix"];

	OCMockObject *viewControllerMock = [OCMockObject mockForClass:[NSArrayController class]];
	NSArray *selectedObjects = [NSArray arrayWithObject:[NSDictionary dictionaryWithObject:@"new" forKey:@"name"]];
	[[[viewControllerMock stub] andReturn:selectedObjects] selectedObjects];
	[controller setValue:viewControllerMock forKey:@"chooseProjectsViewController"];
}


- (void)testAddsProjectWithRightUrlAndNameToDefaults
{
	[controller addProjectsSheetDidEnd:nil returnCode:1 contextInfo:0];

	NSArray *projectList = [NSUnarchiver unarchiveObjectWithData:defaultsData];
	STAssertEquals(1u, [projectList count], @"Should have added one project.");
	NSDictionary *projectListEntry = [projectList objectAtIndex:0];
	STAssertEqualObjects(@"http://test/cctray.xml", [projectListEntry objectForKey:@"serverUrl"], @"Should have set right URL.");
	STAssertEqualObjects(@"new", [projectListEntry objectForKey:@"projectName"], @"Should have set right project name.");
}

- (void)testAddsProjectToExistingList
{
	NSDictionary *pd1 = [NSDictionary dictionaryWithObjectsAndKeys:@"old", @"projectName", @"http://test/cctray.xml", @"serverUrl", nil];
	defaultsData = [NSArchiver archivedDataWithRootObject:[NSArray arrayWithObject:pd1]];
	
	[controller addProjectsSheetDidEnd:nil returnCode:1 contextInfo:0];
	
	NSArray *projectList = [NSUnarchiver unarchiveObjectWithData:defaultsData];
	STAssertEquals(2u, [projectList count], @"Should have added one project.");
	STAssertEqualObjects(@"old", [[projectList objectAtIndex:0] objectForKey:@"projectName"], @"Should have kept project.");
	STAssertEqualObjects(@"new", [[projectList objectAtIndex:1] objectForKey:@"projectName"], @"Should have added project.");
}

- (void)testDoesNotAddProjectsAlreadyPresent
{
	NSDictionary *pd1 = [NSDictionary dictionaryWithObjectsAndKeys:@"new", @"projectName", @"http://test/cctray.xml", @"serverUrl", nil];
	defaultsData = [NSArchiver archivedDataWithRootObject:[NSArray arrayWithObject:pd1]];
	
	[controller addProjectsSheetDidEnd:nil returnCode:1 contextInfo:0];
	
	NSArray *projectList = [NSUnarchiver unarchiveObjectWithData:defaultsData];
	STAssertEquals(1u, [projectList count], @"Should not have added project.");
	STAssertEqualObjects(@"new", [[projectList objectAtIndex:0] objectForKey:@"projectName"], @"Should have kept project.");
}


// user defaults stub

- (NSData *)dataForKey:(NSString *)aKey
{
	if([aKey isEqualToString:CCMDefaultsProjectListKey])
		return defaultsData;
	return nil;
}

- (void)setObject:(id)anObject forKey:(id)aKey
{
	if([aKey isEqualToString:CCMDefaultsProjectListKey])
		defaultsData = anObject;
}

@end
