
#import "NSObject+CCMAdditions.h"

@interface _CCMDefaultValueProvider : NSObject
{
	NSObject	*object;
    id          defaultValue;
}

@end

@implementation _CCMDefaultValueProvider

- (id)initWithObject:(NSObject *)anObject andDefaultValue:(id)someValue
{
	[super init];
	object = [anObject retain];
    defaultValue = [someValue retain];
	return self;
}

- (void)dealloc
{
	[object release];
    [defaultValue release];
	[super dealloc];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	return [object methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    [anInvocation setTarget:object];
    [anInvocation invoke];
    id returnValue = nil;
    [anInvocation getReturnValue:&returnValue];
	if(returnValue == nil)
        [anInvocation setReturnValue:&defaultValue];
    [anInvocation setTarget:self];
    
}

@end


@implementation NSObject(CCMAdditions)

- (id)getWithDefault:(id)defaultValue
{
	return [[[_CCMDefaultValueProvider alloc] initWithObject:self andDefaultValue:defaultValue] autorelease];
}

@end
