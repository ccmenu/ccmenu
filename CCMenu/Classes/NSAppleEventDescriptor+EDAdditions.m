
#import "NSAppleEventDescriptor+EDAdditions.h"


@implementation NSAppleEventDescriptor(EDAdditions)

//---------------------------------------------------------------------------------------
//	creating descriptors with Objective-C types
//---------------------------------------------------------------------------------------

+ (NSAppleEventDescriptor *)descriptorWithValue:(id)value
{
	if([value isKindOfClass:[NSNumber class]])		return [self descriptorWithInt32:[value intValue]];
	if([value isKindOfClass:[NSString class]])		return [self descriptorWithString:value];
	if([value isKindOfClass:[NSArray class]])		return [self descriptorWithArray:value];

	return nil;
}

+ (NSAppleEventDescriptor *)descriptorWithArray:(NSArray *)array
{
    NSAppleEventDescriptor *descriptor = [[[NSAppleEventDescriptor alloc] initListDescriptor] autorelease];
	for(int i = 0; i < [array count]; i++)
		[descriptor insertDescriptor:[self descriptorWithValue:[array objectAtIndex:i]] atIndex:i+1];
	return descriptor;
}


//---------------------------------------------------------------------------------------
//	converting descriptors to Objective-C types
//---------------------------------------------------------------------------------------

- (id)naturalValue
{
	DescType type = [self descriptorType];
	
	if(type == typeTrue)			return [NSNumber numberWithInt:1];
	if(type == typeFalse)			return [NSNumber numberWithInt:0];
	if(type == typeSInt32)			return [NSNumber numberWithInt:[self int32Value]];
	if(type == typeChar)			return [self stringValue];
	if(type == 'utxt')				return [self stringValue];
	if(type == typeAERecord)		return [self recordValue];
	if(type == typeAEList)			return [self listValue];
	
	return nil;
}


- (NSArray *)listValue
{
	NSMutableArray *result = [NSMutableArray array];
	for(int i = 1; i <= [self numberOfItems]; i++)
		[result addObject:[[self descriptorAtIndex:i] naturalValue]];
	return result;	
}


- (NSDictionary *)recordValue
{
	NSAppleEventDescriptor *innerList = [self descriptorAtIndex:1];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	for(int i = 1; i <= [innerList numberOfItems]; i = i + 2)
		[result setValue:[[innerList descriptorAtIndex:i + 1] naturalValue] forKey:[[innerList descriptorAtIndex:i] naturalValue]];
	return result;
}

@end
