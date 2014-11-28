
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "NSArray+CCMAdditions.h"


@interface NSArray_CCMAdditionsTest : XCTestCase
{
}

@end


@implementation NSArray_CCMAdditionsTest

- (void)testArrayCollect
{
    NSArray *original = @[@{@"name" : @"foo"}, @{@"name" : @"bar"}];
	
	NSArray *result = [[original collect] objectForKey:@"name"];

	XCTAssertEqualObjects(@"foo", [result objectAtIndex:0], @"Should have mapped object.");
	XCTAssertEqualObjects(@"bar", [result objectAtIndex:1], @"Should have mapped object.");
	XCTAssertEqual(2ul, [result count], @"Should have returned array of same size.");
}

- (void)testArrayCollectSkipsNilValues
{
    NSArray *original = @[@{@"nameX" : @"foo"}, @{@"name" : @"bar"}];
	
	NSArray *result = [[original collect] objectForKey:@"name"];
	
	XCTAssertEqualObjects(@"bar", [result objectAtIndex:0], @"Should have mapped object.");
	XCTAssertEqual(1ul, [result count], @"Should have returned array correct size.");
}

- (void)testArrayCollectWorksWithEmptyArrays
{
	NSArray *result = [[[NSArray array] collect] objectForKey:@"name"];
	
	XCTAssertEqual(0ul, [result count], @"Should have returned emptyArray.");
}

- (void)testArrayEach
{
	OCMockObject *mock1 = [OCMockObject mockForClass:[NSString class]];
	[[mock1 expect] lowercaseString];
	OCMockObject *mock2 = [OCMockObject mockForClass:[NSString class]];
	[[mock2 expect] lowercaseString];
	NSArray *objects = @[mock1, mock2];
	
	[[objects each] lowercaseString];
	
	[mock1 verify];
	[mock2 verify];
}

- (void)testArrayEachWorksWithEmptyArrays
{
	XCTAssertNoThrow([[[NSArray array] collect] objectForKey:@"name"], @"Should ignore each on empty array");
}



@end


