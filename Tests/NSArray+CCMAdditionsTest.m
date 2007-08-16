
#import "NSArray+CCMAdditionsTest.h"
#import "NSArray+CCMAdditions.h"


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

@end


