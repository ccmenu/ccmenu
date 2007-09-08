
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


- (void)testAddsProjectListEntriesForProjectInfos
{
	[[[defaultsMock expect] andReturn:nil] dataForKey:CCMDefaultsProjectListKey];

	// We have to create the dictionary this way, otherwise it serialises differently and data doesn't match
	NSDictionary *ple = [NSDictionary dictionaryWithObjectsAndKeys:@"new", CCMDefaultsProjectEntryNameKey, 
															@"http://test/cctray.xml", CCMDefaultsProjectEntryServerUrlKey, nil];
	NSData *newData = [NSArchiver archivedDataWithRootObject:[NSArray arrayWithObject:ple]];
	[[defaultsMock expect] setObject:newData forKey:CCMDefaultsProjectListKey];
	
	NSDictionary *pi = [@"{ name = new; }" propertyList];
	NSURL *url = [NSURL URLWithString:@"http://test/cctray.xml"];
	
	[manager updateWithProjectInfos:[NSArray arrayWithObject:pi] withServerURL:url];
}


- (void)testSkipsProjectInfosAlreadyInList
{
	NSDictionary *ple = [@"{ projectName = old; serverUrl = 'http://test/cctray.xml'; }" propertyList];
	NSData *oldData = [NSArchiver archivedDataWithRootObject:[NSArray arrayWithObject:ple]];
	[[[defaultsMock expect] andReturn:oldData] dataForKey:CCMDefaultsProjectListKey];
	
	[[defaultsMock expect] setObject:oldData forKey:CCMDefaultsProjectListKey];
	
	NSDictionary *pi = [@"{ name = old; }" propertyList];
	NSURL *url = [NSURL URLWithString:@"http://test/cctray.xml"];
	
	[manager updateWithProjectInfos:[NSArray arrayWithObject:pi] withServerURL:url];
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


@end
