
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
	id mock1 = OCMClassMock([NSString class]);
    id mock2 = OCMClassMock([NSString class]);

    [[@[mock1, mock2] each] lowercaseString];

    OCMVerify([mock1 lowercaseString]);
    OCMVerify([mock2 lowercaseString]);
}

- (void)testArrayEachWorksWithEmptyArrays
{
	XCTAssertNoThrow([[[NSArray array] collect] objectForKey:@"name"], @"Should ignore each on empty array");
}



@end


