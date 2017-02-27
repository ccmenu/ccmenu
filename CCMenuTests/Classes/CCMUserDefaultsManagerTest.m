
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CCMUserDefaultsManager.h"
#import "CCMProject.h"
#import "CCMBuildNotificationFactory.h"


@interface CCMUserDefaultsManagerTest : XCTestCase
{
	CCMUserDefaultsManager	*manager;
	id			            defaultsMock;
}

@end

    
@implementation CCMUserDefaultsManagerTest

- (void)setUp
{
	manager = [[[CCMUserDefaultsManager alloc] init] autorelease];
	defaultsMock = OCMClassMock([NSUserDefaults class]);
	[manager setValue:defaultsMock forKey:@"userDefaults"];
}

- (void)testRetrievesPollInterval
{
    OCMStub([defaultsMock integerForKey:CCMDefaultsPollIntervalKey]).andReturn(1000);
	
	NSInteger interval = [manager pollInterval];
	
	XCTAssertEqual((NSInteger)1000, interval, @"Should have returned right interval.");
}

- (void)testRetrievesEmptyListFromNonExistentDefaults
{
    OCMStub([defaultsMock arrayForKey:CCMDefaultsProjectListKey]).andReturn(nil);
	
	NSArray *entries = [manager projectList];
	
	XCTAssertNotNil(entries, @"Should have returned empty list.");
	XCTAssertEqual(0ul, [entries count], @"Should have returned empty list.");
}

- (void)testReturnsNilWhenSoundIsTurnedOff
{
    OCMStub([defaultsMock boolForKey:@"PlaySound Successful"]).andReturn(NO);
    OCMStub([defaultsMock stringForKey:@"Sound Successful"]).andReturn(@"Sosumi");

    NSString *sound = [manager soundForEvent:CCMSuccessfulBuild];

    XCTAssertNil(sound, @"Should have returned nil when playSound flag is off");
}

- (void)testReturnsSoundNameWhenSoundIsTurnedOn
{
    OCMStub([defaultsMock boolForKey:@"PlaySound Successful"]).andReturn(YES);
    OCMStub([defaultsMock stringForKey:@"Sound Successful"]).andReturn(@"Sosumi");

    NSString *sound = [manager soundForEvent:CCMSuccessfulBuild];

    XCTAssertEqualObjects(@"Sosumi", sound, @"Should have returned sound name when playSound flag is on");
}

- (void)testRetrievesProjectListFromDefaults
{
	NSArray *list = [@"({ projectName = nameOnServer; serverUrl = 'http://test/cctray.xml'; displayName = nameToDisplay; })" propertyList];
    OCMStub([defaultsMock arrayForKey:CCMDefaultsProjectListKey]).andReturn(list);

	NSArray *projectList = [manager projectList];
	
	XCTAssertEqual(1ul, [projectList count], @"Should have returned one project.");
	CCMProject *project = [projectList objectAtIndex:0];
	XCTAssertEqualObjects(@"nameOnServer", [project name], @"Should have set right project name.");
	XCTAssertEqualObjects(@"http://test/cctray.xml", [project serverURL], @"Should have set right URL.");
	XCTAssertEqualObjects(@"nameToDisplay", [project displayName], @"Should have set right display name.");
}

- (void)testCanCheckWhichProjectsAreInList
{
	NSArray *pl = [@"({ projectName = project1; serverUrl = 'http://test/cctray.xml'; })" propertyList];
    OCMStub([defaultsMock arrayForKey:CCMDefaultsProjectListKey]).andReturn(pl);

	BOOL isInList = [manager projectListContainsProject:@"project1" onServerWithURL:@"http://test/cctray.xml"];
	XCTAssertTrue(isInList, @"Should have returned true for matching project.");

	isInList = [manager projectListContainsProject:@"otherProject" onServerWithURL:@"http://test/cctray.xml"];
	XCTAssertFalse(isInList, @"Should have returned false for not matching project name.");
	
	isInList = [manager projectListContainsProject:@"project1" onServerWithURL:@"http://otherserver/cctray.xml"];
	XCTAssertFalse(isInList, @"Should have returned false for not matching url.");
}

- (void)testAddsProjects
{
    OCMStub([defaultsMock arrayForKey:CCMDefaultsProjectListKey]).andReturn(nil);

	[manager addProject:[[[CCMProject alloc] initWithName:@"new" andServerURL:@"http://localhost/cctray.xml"] autorelease]];

    NSArray *pl = @[@{CCMDefaultsProjectEntryNameKey : @"new", CCMDefaultsProjectEntryServerUrlKey : @"http://localhost/cctray.xml"}];
    OCMVerify([defaultsMock setObject:pl forKey:CCMDefaultsProjectListKey]);
}

- (void)testStoresDisplayNameWhenSet
{
    OCMStub([defaultsMock arrayForKey:CCMDefaultsProjectListKey]).andReturn(nil);

    CCMProject *project = [[[CCMProject alloc] initWithName:@"new" andServerURL:@"http://localhost/cctray.xml"] autorelease];
    [project setDisplayName:@"NEW"];
    [manager addProject:project];

    NSArray *pl = @[@{CCMDefaultsProjectEntryNameKey : @"new", CCMDefaultsProjectEntryServerUrlKey : @"http://localhost/cctray.xml", CCMDefaultsProjectEntryDisplayNameKey : @"NEW"}];
    OCMVerify([defaultsMock setObject:pl forKey:CCMDefaultsProjectListKey]);
}

- (void)testDoesNotAddProjectsAlreadyInList
{
	NSDictionary *pl = [@"({ projectName = project1; serverUrl = 'http://localhost/cctray.xml'; })" propertyList];
    OCMStub([defaultsMock arrayForKey:CCMDefaultsProjectListKey]).andReturn(pl);
    [[defaultsMock reject] setObject:[OCMArg any] forKey:CCMDefaultsProjectListKey];

    [manager addProject:[[[CCMProject alloc] initWithName:@"project1" andServerURL:@"http://localhost/cctray.xml"] autorelease]];
}

- (void)testConvertsDataBasedListIfArrayIsNotAvailable
{
	NSArray *projectList = [@"({ projectName = legacy; serverUrl = 'http://test/cctray.xml'; })" propertyList];
	NSData *defaultsData = [NSArchiver archivedDataWithRootObject:projectList];
    OCMStub([defaultsMock arrayForKey:CCMDefaultsProjectListKey]).andReturn(nil);
    OCMStub([defaultsMock dataForKey:CCMDefaultsProjectListKey]).andReturn(defaultsData);

	[manager convertDefaultsIfNecessary];
	
    OCMVerify([defaultsMock setObject:projectList forKey:CCMDefaultsProjectListKey]);
}

- (void)testAddsPlaySoundKeyWithTrueValueWhenKeyWasNotSetButSoundWasSet
{
    OCMStub([defaultsMock objectForKey:@"PlaySound Successful"]).andReturn(nil);
    OCMStub([defaultsMock stringForKey:@"Sound Successful"]).andReturn(@"Dummy Sound Name");

    [manager convertDefaultsIfNecessary];

    OCMVerify([defaultsMock setBool:YES forKey:@"PlaySound Successful"]);
}

- (void)testAddsPlaySoundKeyWithFalseValueAndSelectsDefaultSoundWhenKeyWasNotSetButSoundWasSetAndHadTheNoSoundValue
{
    OCMStub([defaultsMock objectForKey:@"PlaySound Successful"]).andReturn(nil);
    OCMStub([defaultsMock stringForKey:@"Sound Successful"]).andReturn(@"-");

    [manager convertDefaultsIfNecessary];

    OCMVerify([defaultsMock setBool:NO forKey:@"PlaySound Successful"]);
    OCMVerify([defaultsMock setObject:@"Sosumi" forKey:@"Sound Successful"]);
}

- (void)testAddsPlaySoundKeyWithFalseValueWhenKeyWasNotSetAndSoundWasNotSetEither
{
    OCMStub([defaultsMock objectForKey:@"PlaySound Successful"]).andReturn(nil);
    OCMStub([defaultsMock stringForKey:@"Sound Successful"]).andReturn(nil);

    [manager convertDefaultsIfNecessary];

    OCMVerify([defaultsMock setBool:NO forKey:@"PlaySound Successful"]);
}

- (void)testAddSendNotificationKeyWhenItDidNotExist
{
    OCMStub([defaultsMock objectForKey:@"SendNotification Successful"]).andReturn(nil);
    OCMStub([defaultsMock objectForKey:@"SendNotification Broken"]).andReturn(@YES);
    OCMStub([defaultsMock objectForKey:@"SendNotification Fixed"]).andReturn(@NO);

    [manager convertDefaultsIfNecessary];

    OCMVerify([defaultsMock setBool:YES forKey:@"SendNotification Successful"]);
}

- (void)testAddsToEmptyServerUrlHistory
{
    OCMStub([defaultsMock arrayForKey:CCMDefaultsServerUrlHistoryKey]).andReturn(@[]);
	NSArray *historyArray = @[@"http://test/cctray.xml"];

	[manager addServerURLToHistory:@"http://test/cctray.xml"];

    OCMVerify([defaultsMock setObject:historyArray forKey:CCMDefaultsServerUrlHistoryKey]);
}

- (void)testAddsToExistingServerUrlHistory
{
    NSArray *const originalHistory = @[@"http://test/cctray.xml"];
    OCMStub([defaultsMock arrayForKey:CCMDefaultsServerUrlHistoryKey]).andReturn(originalHistory);

    [manager addServerURLToHistory:@"http://test2/xml"];

    NSArray *expectedHistory = @[@"http://test/cctray.xml", @"http://test2/xml"];
    OCMVerify([defaultsMock setObject:expectedHistory forKey:CCMDefaultsServerUrlHistoryKey]);
}

- (void)testDoesNotAddDuplicatesToServerUrlHistory
{
    OCMStub([defaultsMock arrayForKey:CCMDefaultsServerUrlHistoryKey]).andReturn(@[@"http://test/cctray.xml"]);
    [[defaultsMock reject] setObject:[OCMArg any] forKey:CCMDefaultsServerUrlHistoryKey];

	[manager addServerURLToHistory:@"http://test/cctray.xml"];
}

- (void)testReturnsServerUrlHistory
{
    OCMStub([defaultsMock arrayForKey:CCMDefaultsServerUrlHistoryKey]).andReturn(@[@"http://test/cctray.xml"]);

	NSArray *history = [manager serverURLHistory];
	
	XCTAssertEqual(1ul, [history count], @"Should have returned correct list.");
	XCTAssertEqualObjects(@"http://test/cctray.xml", [history objectAtIndex:0], @"Should have returned correct list.");
}

- (void)testInitializesServerUrlHistoryFromProjectList
{
    OCMStub([defaultsMock arrayForKey:CCMDefaultsServerUrlHistoryKey]).andReturn(nil);
	NSDictionary *pl = [@"({ projectName = project1; serverUrl = 'http://test/cctray.xml'; })" propertyList];
    OCMStub([defaultsMock arrayForKey:CCMDefaultsProjectListKey]).andReturn(pl);

    NSArray *history = [manager serverURLHistory];

    XCTAssertEqualObjects(@"http://test/cctray.xml", [history objectAtIndex:0], @"Should have returned URL from project list.");
    OCMVerify([defaultsMock setObject:@[@"http://test/cctray.xml"] forKey:CCMDefaultsServerUrlHistoryKey]);
}

@end
