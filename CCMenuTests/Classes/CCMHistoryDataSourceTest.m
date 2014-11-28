#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "CCMUserDefaultsManager.h"
#import "CCMHistoryDataSource.h"


@interface CCMHistoryDataSourceTest : XCTestCase
@end


@implementation CCMHistoryDataSourceTest

- (void)testGetsCountAndSortedValuesFromDefaultsManagerWithOneCall
{
    CCMHistoryDataSource *datasource = [[[CCMHistoryDataSource alloc] init] autorelease];

    id udmMock = [OCMockObject mockForClass:[CCMUserDefaultsManager class]];
    [[[udmMock expect] andReturn:@[@"http://localhost", @"http://cclive.thoughtworks.com/dashboard"]] serverURLHistory];
    [datasource reloadData:udmMock];

    int count = (int)[datasource numberOfItemsInComboBox:nil];
    NSString *item0 = [datasource comboBox:nil objectValueForItemAtIndex:0];
    NSString *item1 = [datasource comboBox:nil objectValueForItemAtIndex:1];

    XCTAssertEqual(2, count, @"Should have returned correct number of objects.");
    XCTAssertEqualObjects(@"http://cclive.thoughtworks.com/dashboard", item0, @"Should have returned correct items in order.");
    XCTAssertEqualObjects(@"http://localhost", item1, @"Should have returned correct items in order.");
}

- (void)testReturnsPrefixMatch
{
    CCMHistoryDataSource *datasource = [[[CCMHistoryDataSource alloc] init] autorelease];

    id udmMock = [OCMockObject mockForClass:[CCMUserDefaultsManager class]];
    [[[udmMock stub] andReturn:@[@"http://localhost"]] serverURLHistory];
    [datasource reloadData:udmMock];

    NSString *completion = [datasource comboBox:nil completedString:@"h"];

    XCTAssertEqualObjects(@"http://localhost", completion, @"Should have completed to first item");
}

- (void)testReturnsHostnameMatch
{
    CCMHistoryDataSource *datasource = [[[CCMHistoryDataSource alloc] init] autorelease];

    id udmMock = [OCMockObject mockForClass:[CCMUserDefaultsManager class]];
    [[[udmMock stub] andReturn:@[@"http://localhost/foo"]] serverURLHistory];
    [datasource reloadData:udmMock];

    NSString *completion = [datasource comboBox:nil completedString:@"l"];

    XCTAssertEqualObjects(@"localhost/foo", completion, @"Should have completed to first item based on hostname prefix");
}

- (void)testReturnsHostnameMatchWhenMatchingEmbeddedCredentialIsPresent
{
    CCMHistoryDataSource *datasource = [[[CCMHistoryDataSource alloc] init] autorelease];

    id udmMock = [OCMockObject mockForClass:[CCMUserDefaultsManager class]];
    [[[udmMock stub] andReturn:@[@"http://ll:password@localhost/foo"]] serverURLHistory];
    [datasource reloadData:udmMock];

    NSString *completion = [datasource comboBox:nil completedString:@"l"];

    XCTAssertEqualObjects(@"localhost/foo", completion, @"Should have completed to first item based on hostname prefix");
}

@end
