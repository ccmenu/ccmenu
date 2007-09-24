
#import "CCMUserDefaultsManagerTest.h"
#import "CCMServer.h"
#import "CCMProject.h"


@implementation CCMUserDefaultsManagerTest

- (void)setUp
{
	manager = [[[CCMUserDefaultsManager alloc] init] autorelease];
	
	defaultsMock = [OCMockObject mockForClass:[NSUserDefaults class]];
	[manager setValue:defaultsMock forKey:@"userDefaults"];
}

- (void)tearDown
{
	[defaultsMock verify];
}


- (void)testRetrievesPollInterval
{
	[[[defaultsMock expect] andReturnValue:[NSNumber numberWithInt:1000]] integerForKey:CCMDefaultsPollIntervalKey];
	
	int interval = [manager pollInterval];
	
	STAssertEquals(1000, interval, @"Should have returned right interval.");
}

- (void)testRetrievesProjectListFromDefaults
{
	NSDictionary *ple = [@"{ projectName = new; serverUrl = 'http://test/cctray.xml'; }" propertyList];
	NSData *defaultsData = [NSArchiver archivedDataWithRootObject:[NSArray arrayWithObject:ple]];
	[[[defaultsMock expect] andReturn:defaultsData] dataForKey:CCMDefaultsProjectListKey];

	NSArray *entries = [manager projectListEntries];
	
	STAssertEquals(1u, [entries count], @"Should have returned one project.");
	NSDictionary *projectListEntry = [entries objectAtIndex:0];
	STAssertEqualObjects(@"new", [projectListEntry objectForKey:@"projectName"], @"Should have set right project name.");
	STAssertEqualObjects(@"http://test/cctray.xml", [projectListEntry objectForKey:@"serverUrl"], @"Should have set right URL.");
}

- (void)testRetrievesEmptyListFromNonExistentDefaults
{
	[[[defaultsMock expect] andReturn:nil] dataForKey:CCMDefaultsProjectListKey];
	
	NSArray *entries = [manager projectListEntries];
	
	STAssertNotNil(entries, @"Should have returned empty list.");
	STAssertEquals(0u, [entries count], @"Should have returned empty list.");
}

- (void)testCanCheckWhichProjectsAreInList
{
	NSDictionary *ple = [@"{ projectName = project1; serverUrl = 'http://test/cctray.xml'; }" propertyList];
	NSData *defaultsData = [NSArchiver archivedDataWithRootObject:[NSArray arrayWithObject:ple]];
	[[[defaultsMock stub] andReturn:defaultsData] dataForKey:CCMDefaultsProjectListKey];
	
	BOOL isInList = [manager projectListContainsProject:@"project1" onServerWithURL:@"http://test/cctray.xml"];
	STAssertTrue(isInList, @"Should have returned true for matching project.");

	isInList = [manager projectListContainsProject:@"otherProject" onServerWithURL:@"http://test/cctray.xml"];
	STAssertFalse(isInList, @"Should have returned false for not matching project name.");
	
	isInList = [manager projectListContainsProject:@"project1" onServerWithURL:@"http://otherserver/cctray.xml"];
	STAssertFalse(isInList, @"Should have returned false for not matching url.");
}

- (void)testAddsProjects
{
	[[[defaultsMock stub] andReturn:nil] dataForKey:CCMDefaultsProjectListKey];

	// We have to create the dictionary this way, otherwise it serialises differently and data doesn't match
	NSDictionary *ple = [NSDictionary dictionaryWithObjectsAndKeys:
				@"new", CCMDefaultsProjectEntryNameKey,	@"http://localhost/cctray.xml", CCMDefaultsProjectEntryServerUrlKey, nil];
	NSData *newData = [NSArchiver archivedDataWithRootObject:[NSArray arrayWithObject:ple]];
	[[defaultsMock expect] setObject:newData forKey:CCMDefaultsProjectListKey];

	[manager addProject:@"new" onServerWithURL:@"http://localhost/cctray.xml"];
}

- (void)testDoesNotAddProjectsAlreadyInList
{
	NSDictionary *ple = [@"{ projectName = project1; serverUrl = 'http://localhost/cctray.xml'; }" propertyList];
	NSData *defaultsData = [NSArchiver archivedDataWithRootObject:[NSArray arrayWithObject:ple]];
	[[[defaultsMock stub] andReturn:defaultsData] dataForKey:CCMDefaultsProjectListKey];
		
	[manager addProject:@"project1" onServerWithURL:@"http://localhost/cctray.xml"];
	// we're not using a nice mock, so if the manager tried to set a new list, the mock would complain
}

- (void)testCreatesDomainObjects
{
	NSDictionary *ple = [@"{ projectName = connectfour; serverUrl = 'http://test/cctray.xml'; }" propertyList];
	NSData *projectDefaultsData = [NSArchiver archivedDataWithRootObject:[NSArray arrayWithObject:ple]];
	[[[defaultsMock expect] andReturn:projectDefaultsData] dataForKey:CCMDefaultsProjectListKey]; 
	
	NSArray *servers = [manager servers];
	
	STAssertEquals(1u, [servers count], @"Should have created server.");
	CCMServer *server = [servers objectAtIndex:0];
	STAssertEqualObjects([NSURL URLWithString:@"http://test/cctray.xml"], [server url], @"Should have set right URL.");
	
	STAssertEquals(1u, [[server projects] count], @"Should have created project.");
	CCMProject *project = [[server projects] objectAtIndex:0];
	STAssertEqualObjects(@"connectfour", [project name], @"Should have set right name.");
}


- (void)testCreatesMinimumNumberOfServers
{
	NSDictionary *ple0 = [@"{ projectName = connectfour; serverUrl = 'http://test/cctray.xml'; }" propertyList];
	NSDictionary *ple1 = [@"{ projectName = cozmoz; serverUrl = 'http://test/cctray.xml'; }" propertyList];
	NSDictionary *ple2 = [@"{ projectName = protest; serverUrl = 'http://another/cctray.xml'; }" propertyList];
	NSData *projectDefaultsData = [NSArchiver archivedDataWithRootObject:[NSArray arrayWithObjects:ple0, ple1, ple2, nil]];
	[[[defaultsMock expect] andReturn:projectDefaultsData] dataForKey:CCMDefaultsProjectListKey]; 
	
	NSArray *servers = [manager servers];
	
	STAssertEquals(2u, [servers count], @"Should have created minimum number of servers.");
}


- (void)testAddsToEmptyServerUrlHistory
{
	[[[defaultsMock stub] andReturn:[NSArray array]] arrayForKey:CCMDefaultsServerUrlHistoryKey];
	NSArray *historyArray = [NSArray arrayWithObject:@"http://test/cctray.xml"];
	[[defaultsMock expect] setObject:historyArray forKey:CCMDefaultsServerUrlHistoryKey];
	
	[manager addServerURLToHistory:@"http://test/cctray.xml"];
}

- (void)testAddsToExistingServerUrlHistory
{
	[[[defaultsMock stub] andReturn:[NSArray arrayWithObject:@"http://test/cctray.xml"]] arrayForKey:CCMDefaultsServerUrlHistoryKey];
	NSArray *historyArray = [NSArray arrayWithObjects:@"http://test/cctray.xml", @"http://test2/xml", nil];
	[[defaultsMock expect] setObject:historyArray forKey:CCMDefaultsServerUrlHistoryKey];
	
	[manager addServerURLToHistory:@"http://test2/xml"];
}

- (void)testDoesNotAddDuplicatesToServerUrlHistory
{
	[[[defaultsMock stub] andReturn:[NSArray arrayWithObject:@"http://test/cctray.xml"]] arrayForKey:CCMDefaultsServerUrlHistoryKey];
	
	[manager addServerURLToHistory:@"http://test/cctray.xml"];
    // we're not using a nice mock, so if the manager tried to set a new list, the mock would complain
}

- (void)testReturnsServerUrlHistory
{
	[[[defaultsMock stub] andReturn:[NSArray arrayWithObject:@"http://test/cctray.xml"]] arrayForKey:CCMDefaultsServerUrlHistoryKey];
	
	NSArray *history = [manager serverURLHistory];
	
	STAssertEquals(1u, [history count], @"Should have returned correct list.");
	STAssertEqualObjects(@"http://test/cctray.xml", [history objectAtIndex:0], @"Should have returned correct list.");
}

- (void)testInitializesServerUrlHistoryFromProjectList
{
	[[[defaultsMock stub] andReturn:nil] arrayForKey:CCMDefaultsServerUrlHistoryKey];
	NSDictionary *ple = [@"{ projectName = project1; serverUrl = 'http://test/cctray.xml'; }" propertyList];
	NSData *defaultsData = [NSArchiver archivedDataWithRootObject:[NSArray arrayWithObject:ple]];
	[[[defaultsMock stub] andReturn:defaultsData] dataForKey:CCMDefaultsProjectListKey];

	NSArray *historyArray = [NSArray arrayWithObject:@"http://test/cctray.xml"];
	[[defaultsMock expect] setObject:historyArray forKey:CCMDefaultsServerUrlHistoryKey];
	
	NSArray *history = [manager serverURLHistory];
		
	STAssertEqualObjects(@"http://test/cctray.xml", [history objectAtIndex:0], @"Should have returned URL from project list.");		
}

@end
