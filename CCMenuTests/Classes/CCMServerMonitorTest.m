
#import "CCMServerMonitorTest.h"
#import "CCMUserDefaultsManager.h"
#import "CCMProject.h"
#import "NSArray+CCMAdditions.h"
#import <OCMock/OCMock.h>
#import <EDCommon/EDCommon.h>


@implementation CCMServerMonitorTest

- (void)setUp
{
	monitor = [[[CCMServerMonitor alloc] init] autorelease];
	defaultsManagerMock = [OCMockObject mockForClass:[CCMUserDefaultsManager class]];
	[monitor setDefaultsManager:defaultsManagerMock];
    notificationFactoryMock = [OCMockObject niceMockForClass:[CCMBuildNotificationFactory class]];
    [monitor setNotificationFactory:notificationFactoryMock];
	notificationCenterMock = [OCMockObject niceMockForClass:[NSNotificationCenter class]];
	[monitor setNotificationCenter:notificationCenterMock];
}


- (void)testSetsUpProjectsAndConnectionsFromDefaults
{
	NSArray *defaultsList = [@"({ projectName = connectfour; serverUrl = 'http://test/cctray.xml'; },"
                              " { projectName = cozmoz; serverUrl = 'file:cctray.xml'; },"
                              " { projectName = protest; serverUrl = 'file:cctray.xml'; })" propertyList];
    [[[defaultsManagerMock stub] andReturn:defaultsList] projectList];
    
    [monitor setupFromUserDefaults];
    
    // This also asserts that the projects are in the same order as the defaults; we rely on this in other tests...
    STAssertEquals(3u, [[monitor projects] count], @"Should have created right number of projects.");
    STAssertEqualObjects(@"connectfour", [[[monitor projects] objectAtIndex:0] name], @"Should have created project with correct name.");
    STAssertEqualObjects(@"cozmoz", [[[monitor projects] objectAtIndex:1] name], @"Should have created project with correct name.");
    STAssertEqualObjects(@"protest", [[[monitor projects] objectAtIndex:2] name], @"Should have created project with correct name.");

    STAssertEquals(2u, [[monitor connections] count], @"Should have created minimum number of connection.");
    NSArray *urls = (id)[[[monitor connections] collect] serverURL];
    STAssertTrue([urls indexOfObject:[NSURL URLWithString:@"http://test/cctray.xml"]] != NSNotFound, @"Should have created connection for first URL.");
    STAssertTrue([urls indexOfObject:[NSURL URLWithString:@"file:cctray.xml"]] != NSNotFound, @"Should have created connection for second URL.");
}


- (void)testPostsStatusChangeNotificationWhenNoServersDefined
{
	[[[defaultsManagerMock stub] andReturnValue:[NSNumber numberWithInt:1000]] pollInterval];
	[[[defaultsManagerMock stub] andReturn:[NSArray array]] projectList]; 
	[[notificationCenterMock expect] postNotificationName:CCMProjectStatusUpdateNotification object:monitor];
    
	[monitor start];

    [notificationCenterMock verify];
}


- (void)testUpdatesProjectWithStatusAndPostsNotifications
{
	NSArray *defaultsList = [@"({ projectName = connectfour; serverUrl = 'http://test/cctray.xml'; })" propertyList];
    [[[defaultsManagerMock stub] andReturn:defaultsList] projectList];
    [monitor setupFromUserDefaults];
 	[[notificationCenterMock expect] postNotificationName:CCMProjectStatusUpdateNotification object:monitor];
    NSArray *statusList = [@"({ name = 'connectfour'; lastBuildLabel = 'test1234'; })" propertyList]; 
    
    [monitor connection:[[monitor connections] firstObject] didReceiveServerStatus:statusList];
    
    CCMProject *project = [[monitor projects] firstObject];
    STAssertNil([project statusError], @"Should not have set status error");
    STAssertEqualObjects(@"test1234", [[project status] lastBuildLabel], @"Should have set status.");
    [notificationCenterMock verify];
}


- (void)testUpdatesProjectWhenStatusWasNotIncludedInItsConnectionResponse
{
	NSArray *defaultsList = [@"({ projectName = connectfour; serverUrl = 'http://test/cctray.xml'; })" propertyList];
    [[[defaultsManagerMock stub] andReturn:defaultsList] projectList];
    [monitor setupFromUserDefaults];
 	[[notificationCenterMock expect] postNotificationName:CCMProjectStatusUpdateNotification object:monitor];
    NSArray *statusList = [@"({ name = 'SomeProjectNotConnectfour'; })" propertyList]; 
    
    [monitor connection:[[monitor connections] firstObject] didReceiveServerStatus:statusList];
    
    CCMProject *project = [[monitor projects] firstObject];
    STAssertNotNil([project statusError], @"Should have set a status error");
    STAssertNil(nil, [[project status] lastBuildLabel], @"Should have reset status to nil.");
    [notificationCenterMock verify];
}


- (void)testUpdatesProjectsWithErrorAndPostsNotifications
{
	NSArray *defaultsList = [@"({ projectName = connectfour; serverUrl = 'http://test/cctray.xml'; },"
                              " { projectName = cozmoz; serverUrl = 'file:cctray.xml'; },"
                              " { projectName = protest; serverUrl = 'file:cctray.xml'; })" propertyList];
    [[[defaultsManagerMock stub] andReturn:defaultsList] projectList];
    [monitor setupFromUserDefaults];
    __block CCMConnection *connection = nil;
    [[monitor connections] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([[obj serverURL] isEqual:[NSURL URLWithString:@"file:cctray.xml"]])
            connection = obj;
    }];
 	[[notificationCenterMock expect] postNotificationName:CCMProjectStatusUpdateNotification object:monitor];
   
    [monitor connection:connection hadTemporaryError:@"broken"];
    
    STAssertNil([[[monitor projects] objectAtIndex:0] statusError], @"Should not have set error for project on different server");
    STAssertEqualObjects(@"broken", [[[monitor projects] objectAtIndex:1] statusError], @"Should have set status error");
    STAssertEqualObjects(@"broken", [[[monitor projects] objectAtIndex:2] statusError], @"Should have set status error");
    [notificationCenterMock verify];
}


@end
