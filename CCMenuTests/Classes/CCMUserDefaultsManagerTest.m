
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CCMUserDefaultsManager.h"


@interface CCMUserDefaultsManagerTest : XCTestCase
{
	CCMUserDefaultsManager	*manager;
	OCMockObject			*defaultsMock;
}

@end


#define _verify(mock) \
do { \
    @try { \
        ([mock verify]);\
    } \
    @catch (id anException) { \
         [self recordFailureWithDescription:[anException description] \
                                     inFile:[NSString stringWithCString:__FILE__ encoding:NSASCIIStringEncoding] \
                                     atLine:__LINE__ expected:NO]; \
    }\
} while (0)

    
@implementation CCMUserDefaultsManagerTest

- (void)setUp
{
	manager = [[[CCMUserDefaultsManager alloc] init] autorelease];
	defaultsMock = [OCMockObject niceMockForClass:[NSUserDefaults class]];
	[manager setValue:defaultsMock forKey:@"userDefaults"];
}

- (void)testRetrievesPollInterval
{
	[[[defaultsMock expect] andReturnValue:[NSNumber numberWithInteger:1000]] integerForKey:CCMDefaultsPollIntervalKey];
	
	NSInteger interval = [manager pollInterval];
	
	XCTAssertEqual((NSInteger)1000, interval, @"Should have returned right interval.");
	_verify(defaultsMock);
}

- (void)testRetrievesEmptyListFromNonExistentDefaults
{
	[[[defaultsMock expect] andReturn:nil] arrayForKey:CCMDefaultsProjectListKey];
	
	NSArray *entries = [manager projectList];
	
	XCTAssertNotNil(entries, @"Should have returned empty list.");
	XCTAssertEqual(0ul, [entries count], @"Should have returned empty list.");
	_verify(defaultsMock);
}

- (void)testRetrievesProjectListFromDefaults
{
	NSArray *list = [@"({ projectName = new; serverUrl = 'http://test/cctray.xml'; })" propertyList];
	[[[defaultsMock expect] andReturn:list] arrayForKey:CCMDefaultsProjectListKey];

	NSArray *entries = [manager projectList];
	
	XCTAssertEqual(1ul, [entries count], @"Should have returned one project.");
	NSDictionary *projectListEntry = [entries objectAtIndex:0];
	XCTAssertEqualObjects(@"new", [projectListEntry objectForKey:@"projectName"], @"Should have set right project name.");
	XCTAssertEqualObjects(@"http://test/cctray.xml", [projectListEntry objectForKey:@"serverUrl"], @"Should have set right URL.");
	_verify(defaultsMock);
}

- (void)testCanCheckWhichProjectsAreInList
{
	NSArray *pl = [@"({ projectName = project1; serverUrl = 'http://test/cctray.xml'; })" propertyList];
	[[[defaultsMock stub] andReturn:pl] arrayForKey:CCMDefaultsProjectListKey];
	
	BOOL isInList = [manager projectListContainsProject:@"project1" onServerWithURL:@"http://test/cctray.xml"];
	XCTAssertTrue(isInList, @"Should have returned true for matching project.");

	isInList = [manager projectListContainsProject:@"otherProject" onServerWithURL:@"http://test/cctray.xml"];
	XCTAssertFalse(isInList, @"Should have returned false for not matching project name.");
	
	isInList = [manager projectListContainsProject:@"project1" onServerWithURL:@"http://otherserver/cctray.xml"];
	XCTAssertFalse(isInList, @"Should have returned false for not matching url.");
}

- (void)testAddsProjects
{
	[[[defaultsMock stub] andReturn:nil] arrayForKey:CCMDefaultsProjectListKey];

	// We have to create the dictionary this way, otherwise it serialises differently and data doesn't match
	NSArray *pl = @[@{CCMDefaultsProjectEntryNameKey : @"new", CCMDefaultsProjectEntryServerUrlKey : @"http://localhost/cctray.xml"}];
	[[defaultsMock expect] setObject:pl forKey:CCMDefaultsProjectListKey];

	[manager addProject:@"new" onServerWithURL:@"http://localhost/cctray.xml"];
}

- (void)testDoesNotAddProjectsAlreadyInList
{
	NSDictionary *pl = [@"({ projectName = project1; serverUrl = 'http://localhost/cctray.xml'; })" propertyList];
	[[[defaultsMock stub] andReturn:pl] arrayForKey:CCMDefaultsProjectListKey];
		
	[manager addProject:@"project1" onServerWithURL:@"http://localhost/cctray.xml"];
	// we're not using a nice mock, so if the manager tried to set a new list, the mock would complain
}

- (void)testConvertsDataBasedListIfArrayIsNotAvailable
{
	NSArray *projectList = [@"({ projectName = legacy; serverUrl = 'http://test/cctray.xml'; })" propertyList];
	NSData *defaultsData = [NSArchiver archivedDataWithRootObject:projectList];
	[[[defaultsMock stub] andReturn:nil] arrayForKey:CCMDefaultsProjectListKey];
	[[[defaultsMock expect] andReturn:defaultsData] dataForKey:CCMDefaultsProjectListKey];
    [[defaultsMock expect] setObject:projectList forKey:CCMDefaultsProjectListKey];
    
	[manager convertDefaultsIfNecessary];
	
    _verify(defaultsMock);
}


- (void)testAddsToEmptyServerUrlHistory
{
	[[[defaultsMock stub] andReturn:[NSArray array]] arrayForKey:CCMDefaultsServerUrlHistoryKey];
	NSArray *historyArray = @[@"http://test/cctray.xml"];
	[[defaultsMock expect] setObject:historyArray forKey:CCMDefaultsServerUrlHistoryKey];
	
	[manager addServerURLToHistory:@"http://test/cctray.xml"];

	_verify(defaultsMock);
}

- (void)testAddsToExistingServerUrlHistory
{
	[[[defaultsMock stub] andReturn:@[@"http://test/cctray.xml"]] arrayForKey:CCMDefaultsServerUrlHistoryKey];
	NSArray *historyArray = @[@"http://test/cctray.xml", @"http://test2/xml"];
	[[defaultsMock expect] setObject:historyArray forKey:CCMDefaultsServerUrlHistoryKey];
	
	[manager addServerURLToHistory:@"http://test2/xml"];

	_verify(defaultsMock);
}

- (void)testDoesNotAddDuplicatesToServerUrlHistory
{
	[[[defaultsMock stub] andReturn:@[@"http://test/cctray.xml"]] arrayForKey:CCMDefaultsServerUrlHistoryKey];
	
	[manager addServerURLToHistory:@"http://test/cctray.xml"];

	_verify(defaultsMock);
}

- (void)testReturnsServerUrlHistory
{
	[[[defaultsMock stub] andReturn:@[@"http://test/cctray.xml"]] arrayForKey:CCMDefaultsServerUrlHistoryKey];
	
	NSArray *history = [manager serverURLHistory];
	
	XCTAssertEqual(1ul, [history count], @"Should have returned correct list.");
	XCTAssertEqualObjects(@"http://test/cctray.xml", [history objectAtIndex:0], @"Should have returned correct list.");
}

- (void)testInitializesServerUrlHistoryFromProjectList
{
	[[[defaultsMock stub] andReturn:nil] arrayForKey:CCMDefaultsServerUrlHistoryKey];
	NSDictionary *pl = [@"({ projectName = project1; serverUrl = 'http://test/cctray.xml'; })" propertyList];
	[[[defaultsMock stub] andReturn:pl] arrayForKey:CCMDefaultsProjectListKey];

	NSArray *historyArray = @[@"http://test/cctray.xml"];
	[[defaultsMock expect] setObject:historyArray forKey:CCMDefaultsServerUrlHistoryKey];
	
	NSArray *history = [manager serverURLHistory];
		
	XCTAssertEqualObjects(@"http://test/cctray.xml", [history objectAtIndex:0], @"Should have returned URL from project list.");		
}

@end
