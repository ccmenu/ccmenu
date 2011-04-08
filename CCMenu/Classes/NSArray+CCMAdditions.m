
#import "NSArray+CCMAdditions.h"

@interface _CCMArrayInvoker : NSObject
{
	NSArray	*array;
}

@end

@implementation _CCMArrayInvoker

- (id)initWithArray:(NSArray *)anArray
{
	[super init];
	array = [anArray retain];
	return self;
}

- (void)dealloc
{
	[array release];
	[super dealloc];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	if([array count] == 0)
	{
		// this is not correct, but we don't really care, we just need something that return an object
		return [super methodSignatureForSelector:@selector(init)]; 
	}
	return [[array objectAtIndex:0] methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	NSEnumerator *objectEnumerator = [array objectEnumerator];
	NSObject *object;
	while((object = [objectEnumerator nextObject]) != nil)
	{
		[anInvocation setTarget:object];
		[anInvocation invoke];
	}
	[anInvocation setTarget:self];
}

@end


@interface _CCMArrayCollector : _CCMArrayInvoker
{
}

@end

@implementation _CCMArrayCollector

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	NSMutableArray *result = [NSMutableArray array];
	NSEnumerator *objectEnumerator = [array objectEnumerator];
	NSObject *object;
	while((object = [objectEnumerator nextObject]) != nil)
	{
		id returnValue;
		[anInvocation setTarget:object];
		[anInvocation invoke];
		[anInvocation getReturnValue:&returnValue];
		if(returnValue != nil)
			[result addObject:returnValue];
	}
	[anInvocation setTarget:self];
	[anInvocation setReturnValue:&result];
}

@end




@implementation NSArray(CCMCollectionAdditions)

- (id)each
{
	return [[[_CCMArrayInvoker alloc] initWithArray:self] autorelease];
}

- (id)collect
{
	return [[[_CCMArrayCollector alloc] initWithArray:self] autorelease];
}

@end
