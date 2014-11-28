
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CCMProjectSheetController.h"
#import "NSString+CCMAdditions.h"


@interface CCMProjectSheetControllerTest : XCTestCase
{
    CCMProjectSheetController *controller;

	OCMockObject *defaultsManagerMock;
	OCMockObject *serverUrlComboBoxMock;
	OCMockObject *serverTypeMatrixMock;
}

@end


@implementation CCMProjectSheetControllerTest

- (void)setUp
{
	controller = [[[CCMProjectSheetController alloc] init] autorelease];
	
	defaultsManagerMock = [OCMockObject mockForClass:[CCMUserDefaultsManager class]];
	[controller setValue:defaultsManagerMock forKey:@"defaultsManager"];
	
	serverUrlComboBoxMock = [OCMockObject mockForClass:[NSComboBox class]];
	[controller setValue:serverUrlComboBoxMock forKey:@"urlComboBox"];
	
	serverTypeMatrixMock = [OCMockObject mockForClass:[NSMatrix class]];
	[controller setValue:serverTypeMatrixMock forKey:@"serverTypeMatrix"];
}

- (void)tearDown
{
	[defaultsManagerMock verify];
	[serverUrlComboBoxMock verify];
	[serverTypeMatrixMock verify];
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

- (void)testAddUserAndSchemeToUrlWhenUserFieldIsEditedAndUrlHadNoUserOrScheme
{
    id userFieldMock = [OCMockObject mockForClass:[NSTextField class]];
    [controller setValue:userFieldMock forKey:@"userField"];
    
    [[[serverUrlComboBoxMock stub] andReturn:@"host.com/feed"] stringValue];
    [[[userFieldMock stub] andReturn:@"alice"] stringValue];
    [[serverUrlComboBoxMock expect] setStringValue:@"http://alice@host.com/feed"];
    
    [controller controlTextDidChange:[NSNotification notificationWithName:@"test" object:userFieldMock]];
}

- (void)testReplacesUserInUrlWhenUserFieldIsEdited
{
    id userFieldMock = [OCMockObject mockForClass:[NSTextField class]];
    [controller setValue:userFieldMock forKey:@"userField"];
    
    [[[serverUrlComboBoxMock stub] andReturn:@"https://alice@host.com/feed"] stringValue];
    [[[userFieldMock stub] andReturn:@"bob"] stringValue];
    [[serverUrlComboBoxMock expect] setStringValue:@"https://bob@host.com/feed"];
    
    [controller controlTextDidChange:[NSNotification notificationWithName:@"test" object:userFieldMock]];
}

- (void)testReplacesUserInUrlAndAddsSchemeWhenUserFieldIsEditedAndUrlHasNoScheme
{
    id userFieldMock = [OCMockObject mockForClass:[NSTextField class]];
    [controller setValue:userFieldMock forKey:@"userField"];
    
    [[[serverUrlComboBoxMock stub] andReturn:@"alice@host.com/feed"] stringValue];
    [[[userFieldMock stub] andReturn:@"bob"] stringValue];
    [[serverUrlComboBoxMock expect] setStringValue:@"http://bob@host.com/feed"];
    
    [controller controlTextDidChange:[NSNotification notificationWithName:@"test" object:userFieldMock]];
}

- (void)testAddsProjectWithServerUrlAndNameToDefaults
{
	OCMockObject *viewControllerMock = [OCMockObject mockForClass:[NSArrayController class]];
	[controller setValue:viewControllerMock forKey:@"chooseProjectsViewController"];
	NSArray *selectedObjects = [@"( { name = new; server = 'http://test/cctray.xml'; } )" propertyList];
	[[[viewControllerMock stub] andReturn:selectedObjects] selectedObjects];
	
	[[defaultsManagerMock expect] addProject:@"new" onServerWithURL:@"http://test/cctray.xml"];
	[[defaultsManagerMock expect] addServerURLToHistory:@"http://test/cctray.xml"];
	
	[controller sheetDidEnd:nil returnCode:1 contextInfo:0];
}

@end
