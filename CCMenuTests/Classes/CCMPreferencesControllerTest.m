
#import "CCMPreferencesControllerTest.h"
#import "CCMPreferencesController.h"
#import "CCMUserDefaultsManager.h"
#import "NSString+CCMAdditions.h"


@implementation CCMPreferencesControllerTest

- (void)setUp
{
	controller = [[[CCMPreferencesController alloc] init] autorelease];
	
	defaultsManagerMock = [OCMockObject mockForClass:[CCMUserDefaultsManager class]];
	[controller setValue:defaultsManagerMock forKey:@"defaultsManager"];
	
	serverUrlComboBoxMock = [OCMockObject mockForClass:[NSComboBox class]];
	[controller setValue:serverUrlComboBoxMock forKey:@"serverUrlComboBox"];
	
	serverTypeMatrixMock = [OCMockObject mockForClass:[NSMatrix class]];
	[controller setValue:serverTypeMatrixMock forKey:@"serverTypeMatrix"];
}

- (void)tearDown
{
	[defaultsManagerMock verify];
	[serverUrlComboBoxMock verify];
	[serverTypeMatrixMock verify];
}

- (void)testSelectsServerTypeWhenHistoryURLIsSelected
{
	[[serverTypeMatrixMock expect] selectCellWithTag:CCMUseGivenURL];

	[controller historyURLSelected:nil];
}

- (void)testAddsHttpSchemeWhenSwitchingOffDetectionAndNoSchemePresent
{
	[[[serverUrlComboBoxMock stub] andReturn:@"test"] stringValue];
	[[[serverTypeMatrixMock stub] andReturnValue:OCMOCK_VALUE((NSInteger){CCMUseGivenURL})] selectedTag];
	[[serverUrlComboBoxMock expect] setStringValue:@"http://test"];
		
	[controller serverDetectionChanged:nil];
}

- (void)testDoesNotAddsHttpSchemeWhenSwitchingOffDetectionAndSchemePresent
{
    [[[serverUrlComboBoxMock stub] andReturn:@"https://test"] stringValue];
    [[[serverTypeMatrixMock stub] andReturnValue:OCMOCK_VALUE((NSInteger){CCMUseGivenURL})] selectedTag];
    [[serverUrlComboBoxMock expect] setStringValue:@"https://test"];

    [controller serverDetectionChanged:nil];
}

- (void)testAddsProjectWithServerUrlAndNameToDefaults
{
	OCMockObject *viewControllerMock = [OCMockObject mockForClass:[NSArrayController class]];
	[controller setValue:viewControllerMock forKey:@"chooseProjectsViewController"];
	NSArray *selectedObjects = [@"( { name = new; server = 'http://test/cctray.xml'; } )" propertyList];
	[[[viewControllerMock stub] andReturn:selectedObjects] selectedObjects];
	
	[[defaultsManagerMock expect] addProject:@"new" onServerWithURL:@"http://test/cctray.xml"];
	[[defaultsManagerMock expect] addServerURLToHistory:@"http://test/cctray.xml"];
	
	[controller addProjectsSheetDidEnd:nil returnCode:1 contextInfo:0];
}

@end
