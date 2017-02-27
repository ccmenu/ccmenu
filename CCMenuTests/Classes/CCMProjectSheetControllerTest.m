
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CCMProjectSheetController.h"
#import "NSString+CCMAdditions.h"
#import "CCMProject.h"


@interface CCMProjectSheetControllerTest : XCTestCase
{
    CCMProjectSheetController *controller;

	id defaultsManagerMock;
	id serverUrlComboBoxMock;
	id serverTypeMatrixMock;
}

@end


@implementation CCMProjectSheetControllerTest

- (void)setUp
{
	controller = [[[CCMProjectSheetController alloc] init] autorelease];
	
	defaultsManagerMock = OCMClassMock([CCMUserDefaultsManager class]);
	[controller setValue:defaultsManagerMock forKey:@"defaultsManager"];
	
	serverUrlComboBoxMock = OCMClassMock([NSComboBox class]);
	[controller setValue:serverUrlComboBoxMock forKey:@"urlComboBox"];
	
	serverTypeMatrixMock = OCMClassMock([NSMatrix class]);
	[controller setValue:serverTypeMatrixMock forKey:@"serverTypeMatrix"];
}

- (void)testAddsHttpSchemeWhenSwitchingOffDetectionAndNoSchemePresent
{
    OCMStub([serverUrlComboBoxMock stringValue]).andReturn(@"test");
    OCMStub([serverTypeMatrixMock selectedTag]).andReturn(CCMUseGivenURL);
	[[serverUrlComboBoxMock expect] setStringValue:@"http://test"];
    
	[controller serverDetectionChanged:nil];

    OCMVerify([serverUrlComboBoxMock setStringValue:@"http://test"]);
}

- (void)testDoesNotAddsHttpSchemeWhenSwitchingOffDetectionAndSchemePresent
{
    OCMStub([serverUrlComboBoxMock stringValue]).andReturn(@"https://test");
    OCMStub([serverTypeMatrixMock selectedTag]).andReturn(CCMUseGivenURL);

    [controller serverDetectionChanged:nil];

    OCMVerify([serverUrlComboBoxMock setStringValue:@"https://test"]);
}

- (void)testAddUserAndSchemeToUrlWhenUserFieldIsEditedAndUrlHadNoUserOrScheme
{
    id userFieldMock = OCMClassMock([NSTextField class]);
    [controller setValue:userFieldMock forKey:@"userField"];

    OCMStub([serverUrlComboBoxMock stringValue]).andReturn(@"host.com/feed");
    OCMStub([userFieldMock stringValue]).andReturn(@"alice");

    [controller controlTextDidChange:[NSNotification notificationWithName:@"test" object:userFieldMock]];

    OCMVerify([serverUrlComboBoxMock setStringValue:@"http://alice@host.com/feed"]);
}

- (void)testReplacesUserInUrlWhenUserFieldIsEdited
{
    id userFieldMock = OCMClassMock([NSTextField class]);
    [controller setValue:userFieldMock forKey:@"userField"];
    
    OCMStub([serverUrlComboBoxMock stringValue]).andReturn(@"https://alice@host.com/feed");
    OCMStub([userFieldMock stringValue]).andReturn(@"bob");

    [controller controlTextDidChange:[NSNotification notificationWithName:@"test" object:userFieldMock]];

    OCMVerify([serverUrlComboBoxMock setStringValue:@"https://bob@host.com/feed"]);
}

- (void)testReplacesUserInUrlAndAddsSchemeWhenUserFieldIsEditedAndUrlHasNoScheme
{
    id userFieldMock = OCMClassMock([NSTextField class]);
    [controller setValue:userFieldMock forKey:@"userField"];
    
    OCMStub([serverUrlComboBoxMock stringValue]).andReturn(@"alice@host.com/feed");
    OCMStub([userFieldMock stringValue]).andReturn(@"bob");

    [controller controlTextDidChange:[NSNotification notificationWithName:@"test" object:userFieldMock]];

    OCMVerify([serverUrlComboBoxMock setStringValue:@"http://bob@host.com/feed"]);
}

- (void)testAddsProjectWithServerUrlAndNameToDefaults
{
	id viewControllerMock = OCMClassMock([NSArrayController class]);
	[controller setValue:viewControllerMock forKey:@"chooseProjectsViewController"];
    NSArray *selectedObjects = @[@{ @"name": @"new", @"server": @"http://test/cctray.xml"}];
    OCMStub([viewControllerMock selectedObjects]).andReturn(selectedObjects);

	[controller sheetDidEnd:nil returnCode:1 contextInfo:0];

    CCMProject *p = [[[CCMProject alloc] initWithName:@"new" andServerURL:@"http://test/cctray.xml"] autorelease];
    OCMVerify([defaultsManagerMock addProject:p]);
    OCMVerify([defaultsManagerMock addServerURLToHistory:@"http://test/cctray.xml"]);
}

@end
