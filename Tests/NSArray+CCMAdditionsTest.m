
#import "NSArray+CCMAdditionsTest.h"
#import "NSArray+CCMAdditions.h"
#import <OCMock/OCMock.h>


@implementation NSArray_CCMAdditionsTest

- (void)testArrayCollect
{
	NSDictionary *o1 = [NSDictionary dictionaryWithObject:@"foo" forKey:@"name"];
	NSDictionary *o2 = [NSDictionary dictionaryWithObject:@"bar" forKey:@"name"];
	NSArray *original = [NSArray arrayWithObjects:o1, o2, nil];
	
	NSArray *result = [[original collect] objectForKey:@"name"];

	STAssertEqualObjects(@"foo", [result objectAtIndex:0], @"Should have mapped object.");
	STAssertEqualObjects(@"bar", [result objectAtIndex:1], @"Should have mapped object.");
	STAssertEquals(2u, [result count], @"Should have returned array of same size.");
}

- (void)testArrayCollectSkipsNilValues
{
	NSDictionary *o1 = [NSDictionary dictionaryWithObject:@"foo" forKey:@"nameX"];
	NSDictionary *o2 = [NSDictionary dictionaryWithObject:@"bar" forKey:@"name"];
	NSArray *original = [NSArray arrayWithObjects:o1, o2, nil];
	
	NSArray *result = [[original collect] objectForKey:@"name"];
	
	STAssertEqualObjects(@"bar", [result objectAtIndex:0], @"Should have mapped object.");
	STAssertEquals(1u, [result count], @"Should have returned array correct size.");
}

- (void)testArrayCollectWorksWithEmptyArrays
{
	NSArray *result = [[[NSArray array] collect] objectForKey:@"name"];
	
	STAssertEquals(0u, [result count], @"Should have returned emptyArray.");
}

- (void)testArrayEach
{
	OCMockObject *mock1 = [OCMockObject mockForClass:[NSString class]];
	[[mock1 expect] lowercaseString];
	OCMockObject *mock2 = [OCMockObject mockForClass:[NSString class]];
	[[mock2 expect] lowercaseString];
	NSArray *objects = [NSArray arrayWithObjects:mock1, mock2, nil];
	
	[[objects each] lowercaseString];
	
	[mock1 verify];
	[mock2 verify];
}

- (void)testArrayEachWorksWithEmptyArrays
{
	STAssertNoThrow([[[NSArray array] collect] objectForKey:@"name"], @"Should ignore each on empty array");
}



@end


