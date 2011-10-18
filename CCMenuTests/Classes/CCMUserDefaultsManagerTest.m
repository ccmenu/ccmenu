
#import "CCMUserDefaultsManagerTest.h"
#import "CCMProject.h"

#define _verify(mock) \
do { \
    @try { \
        ([mock verify]);\
    } \
    @catch (id anException) { \
        [[NSException failureInFile:[NSString stringWithUTF8String:__FILE__] \
                             atLine:__LINE__ \
                    withDescription:[anException description]] raise]; \
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
	[[[defaultsMock expect] andReturnValue:[NSNumber numberWithInt:1000]] integerForKey:CCMDefaultsPollIntervalKey];
	
	int interval = [manager pollInterval];
	
	STAssertEquals(1000, interval, @"Should have returned right interval.");
	_verify(defaultsMock);
}

- (void)testRetrievesEmptyListFromNonExistentDefaults
{
	[[[defaultsMock expect] andReturn:nil] arrayForKey:CCMDefaultsProjectListKey];
	
	NSArray *entries = [manager projectList];
	
	STAssertNotNil(entries, @"Should have returned empty list.");
	STAssertEquals(0u, [entries count], @"Should have returned empty list.");
	_verify(defaultsMock);
}

- (void)testRetrievesProjectListFromDefaults
{
	NSArray *list = [@"({ projectName = new; serverUrl = 'http://test/cctray.xml'; })" propertyList];
	[[[defaultsMock expect] andReturn:list] arrayForKey:CCMDefaultsProjectListKey];

	NSArray *entries = [manager projectList];
	
	STAssertEquals(1u, [entries count], @"Should have returned one project.");
	NSDictionary *projectListEntry = [entries objectAtIndex:0];
	STAssertEqualObjects(@"new", [projectListEntry objectForKey:@"projectName"], @"Should have set right project name.");
	STAssertEqualObjects(@"http://test/cctray.xml", [projectListEntry objectForKey:@"serverUrl"], @"Should have set right URL.");
	_verify(defaultsMock);
}

- (void)testCanCheckWhichProjectsAreInList
{
	NSArray *pl = [@"({ projectName = project1; serverUrl = 'http://test/cctray.xml'; })" propertyList];
	[[[defaultsMock stub] andReturn:pl] arrayForKey:CCMDefaultsProjectListKey];
	
	BOOL isInList = [manager projectListContainsProject:@"project1" onServerWithURL:@"http://test/cctray.xml"];
	STAssertTrue(isInList, @"Should have returned true for matching project.");

	isInList = [manager projectListContainsProject:@"otherProject" onServerWithURL:@"http://test/cctray.xml"];
	STAssertFalse(isInList, @"Should have returned false for not matching project name.");
	
	isInList = [manager projectListContainsProject:@"project1" onServerWithURL:@"http://otherserver/cctray.xml"];
	STAssertFalse(isInList, @"Should have returned false for not matching url.");
}

- (void)testAddsProjects
{
	[[[defaultsMock stub] andReturn:nil] arrayForKey:CCMDefaultsProjectListKey];

	// We have to create the dictionary this way, otherwise it serialises differently and data doesn't match
	NSArray *pl = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
				@"new", CCMDefaultsProjectEntryNameKey,	@"http://localhost/cctray.xml", CCMDefaultsProjectEntryServerUrlKey, nil]];
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
	NSArray *historyArray = [NSArray arrayWithObject:@"http://test/cctray.xml"];
	[[defaultsMock expect] setObject:historyArray forKey:CCMDefaultsServerUrlHistoryKey];
	
	[manager addServerURLToHistory:@"http://test/cctray.xml"];

	_verify(defaultsMock);
}

- (void)testAddsToExistingServerUrlHistory
{
	[[[defaultsMock stub] andReturn:[NSArray arrayWithObject:@"http://test/cctray.xml"]] arrayForKey:CCMDefaultsServerUrlHistoryKey];
	NSArray *historyArray = [NSArray arrayWithObjects:@"http://test/cctray.xml", @"http://test2/xml", nil];
	[[defaultsMock expect] setObject:historyArray forKey:CCMDefaultsServerUrlHistoryKey];
	
	[manager addServerURLToHistory:@"http://test2/xml"];

	_verify(defaultsMock);
}

- (void)testDoesNotAddDuplicatesToServerUrlHistory
{
	[[[defaultsMock stub] andReturn:[NSArray arrayWithObject:@"http://test/cctray.xml"]] arrayForKey:CCMDefaultsServerUrlHistoryKey];
	
	[manager addServerURLToHistory:@"http://test/cctray.xml"];

	_verify(defaultsMock);
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
	NSDictionary *pl = [@"({ projectName = project1; serverUrl = 'http://test/cctray.xml'; })" propertyList];
	[[[defaultsMock stub] andReturn:pl] arrayForKey:CCMDefaultsProjectListKey];

	NSArray *historyArray = [NSArray arrayWithObject:@"http://test/cctray.xml"];
	[[defaultsMock expect] setObject:historyArray forKey:CCMDefaultsServerUrlHistoryKey];
	
	NSArray *history = [manager serverURLHistory];
		
	STAssertEqualObjects(@"http://test/cctray.xml", [history objectAtIndex:0], @"Should have returned URL from project list.");		
}

@end
