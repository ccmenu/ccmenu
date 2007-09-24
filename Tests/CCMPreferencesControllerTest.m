
#import "CCMPreferencesControllerTest.h"
#import "CCMPreferencesController.h"
#import "CCMUserDefaultsManager.h"


@implementation CCMPreferencesControllerTest

- (void)setUp
{
	controller = [[[CCMPreferencesController alloc] init] autorelease];
	defaultsManagerMock = [OCMockObject mockForClass:[CCMUserDefaultsManager class]];
	[controller setValue:defaultsManagerMock forKey:@"defaultsManager"];
	
	OCMockObject *comboBoxMock = [OCMockObject mockForClass:[NSComboBox class]];
	[controller setValue:comboBoxMock forKey:@"serverUrlComboBox"];
	[[[comboBoxMock stub] andReturn:@"http://test"] stringValue];
	
	OCMockObject *serverTypeMatrixMock = [OCMockObject mockForClass:[NSMatrix class]];
	[controller setValue:serverTypeMatrixMock forKey:@"serverTypeMatrix"];
	[[[serverTypeMatrixMock stub] andReturn:0] selectedTag]; // this tag signals 'cctray.xml'

	OCMockObject *viewControllerMock = [OCMockObject mockForClass:[NSArrayController class]];
	[controller setValue:viewControllerMock forKey:@"chooseProjectsViewController"];
	NSArray *selectedObjects = [NSArray arrayWithObject:[NSDictionary dictionaryWithObject:@"new" forKey:@"name"]];
	[[[viewControllerMock stub] andReturn:selectedObjects] selectedObjects];
}

- (void)tearDown
{
	[defaultsManagerMock verify];
}

- (void)testAppendsExtensionForServerType
{
	NSURL *url = [controller getServerURL];
	STAssertEqualObjects(@"http://test/cctray.xml", [url absoluteString], @"Should have appended extension for server type.");
}

- (void)testPrependsHttpSchemeIfNecessary
{
	OCMockObject *specialComboBoxMock = [OCMockObject mockForClass:[NSComboBox class]];
	[controller setValue:specialComboBoxMock forKey:@"serverUrlComboBox"];
	[[[specialComboBoxMock stub] andReturn:@"test"] stringValue];
	[[specialComboBoxMock expect] setStringValue:@"http://test"];
	
	NSURL *url = [controller getServerURL];
	
	[specialComboBoxMock verify];
	STAssertEqualObjects(@"http://test/cctray.xml", [url absoluteString], @"Should have prepended http scheme.");
}

- (void)testAddsProjectWithServerUrlAndNameToDefaults
{
	[[defaultsManagerMock expect] addProject:@"new" onServerWithURL:@"http://test/cctray.xml"];
	[[defaultsManagerMock expect] addServerURLToHistory:@"http://test/cctray.xml"];
	
	[controller addProjectsSheetDidEnd:nil returnCode:1 contextInfo:0];
}

@end
