#import <OCMock/OCMock.h>
#import "CCMHistoryDataSourceTest.h"
#import "CCMUserDefaultsManager.h"
#import "CCMHistoryDataSource.h"


@implementation CCMHistoryDataSourceTest

- (void)testGetsCountAndSortedValuesFromDefaultsManagerWithOneCall
{
    CCMHistoryDataSource *datasource = [[[CCMHistoryDataSource alloc] init] autorelease];

    id udmMock = [OCMockObject mockForClass:[CCMUserDefaultsManager class]];
    [[[udmMock expect] andReturn:[NSArray arrayWithObjects:@"http://localhost", @"http://cclive.thoughtworks.com/dashboard", nil]] serverURLHistory];
    [datasource reloadData:udmMock];

    int count = (int)[datasource numberOfItemsInComboBox:nil];
    NSString *item0 = [datasource comboBox:nil objectValueForItemAtIndex:0];
    NSString *item1 = [datasource comboBox:nil objectValueForItemAtIndex:1];

    STAssertEquals(2, count, @"Should have returned correct number of objects.");
    STAssertEqualObjects(@"http://cclive.thoughtworks.com/dashboard", item0, @"Should have returned correct items in order.");
    STAssertEqualObjects(@"http://localhost", item1, @"Should have returned correct items in order.");
}

- (void)testReturnsPrefixMatch
{
    CCMHistoryDataSource *datasource = [[[CCMHistoryDataSource alloc] init] autorelease];

    id udmMock = [OCMockObject mockForClass:[CCMUserDefaultsManager class]];
    [[[udmMock stub] andReturn:[NSArray arrayWithObjects:@"http://localhost", nil]] serverURLHistory];
    [datasource reloadData:udmMock];

    NSString *completion = [datasource comboBox:nil completedString:@"h"];

    STAssertEqualObjects(@"http://localhost", completion, @"Should have completed to first item");
}

- (void)testReturnsHostnameMatch
{
    CCMHistoryDataSource *datasource = [[[CCMHistoryDataSource alloc] init] autorelease];

    id udmMock = [OCMockObject mockForClass:[CCMUserDefaultsManager class]];
    [[[udmMock stub] andReturn:[NSArray arrayWithObjects:@"http://localhost/foo", nil]] serverURLHistory];
    [datasource reloadData:udmMock];

    NSString *completion = [datasource comboBox:nil completedString:@"l"];

    STAssertEqualObjects(@"localhost/foo", completion, @"Should have completed to first item based on hostname prefix");
}

- (void)testReturnsHostnameMatchWhenMatchingEmbeddedCredentialIsPresent
{
    CCMHistoryDataSource *datasource = [[[CCMHistoryDataSource alloc] init] autorelease];

    id udmMock = [OCMockObject mockForClass:[CCMUserDefaultsManager class]];
    [[[udmMock stub] andReturn:[NSArray arrayWithObjects:@"http://ll:password@localhost/foo", nil]] serverURLHistory];
    [datasource reloadData:udmMock];

    NSString *completion = [datasource comboBox:nil completedString:@"l"];

    STAssertEqualObjects(@"localhost/foo", completion, @"Should have completed to first item based on hostname prefix");
}

@end
