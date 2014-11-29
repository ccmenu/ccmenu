
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CCMServerMonitor.h"
#import "NSArray+CCMAdditions.h"


@interface CCMServerMonitorTest : XCTestCase
{
	CCMServerMonitor *monitor;
	id               defaultsManagerMock;
    id               notificationFactoryMock;
    id               notificationCenterMock;
}

@end


@implementation CCMServerMonitorTest

- (void)setUp
{
	monitor = [[[CCMServerMonitor alloc] init] autorelease];
	defaultsManagerMock = OCMClassMock([CCMUserDefaultsManager class]);
	[monitor setDefaultsManager:defaultsManagerMock];
    notificationFactoryMock = OCMClassMock([CCMBuildNotificationFactory class]);
    [monitor setNotificationFactory:notificationFactoryMock];
	notificationCenterMock = OCMClassMock([NSNotificationCenter class]);
	[monitor setNotificationCenter:notificationCenterMock];
}


- (void)testSetsUpProjectsAndConnectionsFromDefaults
{
	NSArray *defaultsList = [@"({ projectName = connectfour; serverUrl = 'http://test/cctray.xml'; },"
                              " { projectName = cozmoz; serverUrl = 'file:cctray.xml'; },"
                              " { projectName = protest; serverUrl = 'file:cctray.xml'; })" propertyList];
    OCMStub([defaultsManagerMock projectList]).andReturn(defaultsList);

    [monitor setupFromUserDefaults];
    
    // This also asserts that the projects are in the same order as the defaults; we rely on this in other tests...
    XCTAssertEqual(3ul, [[monitor projects] count], @"Should have created right number of projects.");
    XCTAssertEqualObjects(@"connectfour", [[[monitor projects] objectAtIndex:0] name], @"Should have created project with correct name.");
    XCTAssertEqualObjects(@"cozmoz", [[[monitor projects] objectAtIndex:1] name], @"Should have created project with correct name.");
    XCTAssertEqualObjects(@"protest", [[[monitor projects] objectAtIndex:2] name], @"Should have created project with correct name.");

    XCTAssertEqual(2ul, [[monitor connections] count], @"Should have created minimum number of connection.");
    NSArray *urls = (id) [[[monitor connections] collect] feedURL];
    XCTAssertTrue([urls indexOfObject:[NSURL URLWithString:@"http://test/cctray.xml"]] != NSNotFound, @"Should have created connection for first URL.");
    XCTAssertTrue([urls indexOfObject:[NSURL URLWithString:@"file:cctray.xml"]] != NSNotFound, @"Should have created connection for second URL.");
}


- (void)testPostsStatusChangeNotificationWhenNoServersDefined
{
    OCMStub([defaultsManagerMock pollInterval]).andReturn(1000);
    OCMStub([defaultsManagerMock projectList]).andReturn(@[]);

	[monitor start];

    OCMVerify([notificationCenterMock postNotificationName:CCMProjectStatusUpdateNotification object:monitor]);
}


- (void)testUpdatesProjectWithStatusAndPostsNotifications
{
	NSArray *defaultsList = [@"({ projectName = connectfour; serverUrl = 'http://test/cctray.xml'; })" propertyList];
    OCMStub([defaultsManagerMock projectList]).andReturn(defaultsList);
    [monitor setupFromUserDefaults];
    NSArray *statusList = [@"({ name = 'connectfour'; lastBuildLabel = 'test1234'; })" propertyList];
    
    [monitor connection:[[monitor connections] firstObject] didReceiveServerStatus:statusList];
    
    CCMProject *project = [[monitor projects] firstObject];
    XCTAssertNil([project statusError], @"Should not have set status error");
    XCTAssertEqualObjects(@"test1234", [[project status] lastBuildLabel], @"Should have set status.");
    OCMVerify([notificationCenterMock postNotificationName:CCMProjectStatusUpdateNotification object:monitor]);
}


- (void)testUpdatesProjectWhenStatusWasNotIncludedInItsConnectionResponse
{
	NSArray *defaultsList = [@"({ projectName = connectfour; serverUrl = 'http://test/cctray.xml'; })" propertyList];
    OCMStub([defaultsManagerMock projectList]).andReturn(defaultsList);
    [monitor setupFromUserDefaults];
    NSArray *statusList = [@"({ name = 'SomeProjectNotConnectfour'; })" propertyList];
    
    [monitor connection:[[monitor connections] firstObject] didReceiveServerStatus:statusList];
    
    CCMProject *project = [[monitor projects] firstObject];
    XCTAssertNotNil([project statusError], @"Should have set a status error");
    XCTAssertNil([[project status] lastBuildLabel], @"Should have reset status to nil.");
    OCMVerify([notificationCenterMock postNotificationName:CCMProjectStatusUpdateNotification object:monitor]);
}


- (void)testUpdatesProjectsWithErrorAndPostsNotifications
{
	NSArray *defaultsList = [@"({ projectName = connectfour; serverUrl = 'http://test/cctray.xml'; },"
                              " { projectName = cozmoz; serverUrl = 'file:cctray.xml'; },"
                              " { projectName = protest; serverUrl = 'file:cctray.xml'; })" propertyList];
    OCMStub([defaultsManagerMock projectList]).andReturn(defaultsList);
    [monitor setupFromUserDefaults];
    __block CCMConnection *connection = nil;
    [[monitor connections] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([[obj feedURL] isEqual:[NSURL URLWithString:@"file:cctray.xml"]])
            connection = obj;
    }];

    [monitor connection:connection hadTemporaryError:@"broken"];
    
    XCTAssertNil([[[monitor projects] objectAtIndex:0] statusError], @"Should not have set error for project on different server");
    XCTAssertEqualObjects(@"broken", [[[monitor projects] objectAtIndex:1] statusError], @"Should have set status error");
    XCTAssertEqualObjects(@"broken", [[[monitor projects] objectAtIndex:2] statusError], @"Should have set status error");
    OCMVerify([notificationCenterMock postNotificationName:CCMProjectStatusUpdateNotification object:monitor]);
}


@end
