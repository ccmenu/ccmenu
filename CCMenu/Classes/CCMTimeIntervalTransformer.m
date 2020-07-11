
#import "CCMTimeIntervalTransformer.h"
#import "NSDate+CCMAdditions.h"

NSString *CCMTimeIntervalTransformerName = @"CCMTimeIntervalTransformer";


@implementation CCMTimeIntervalTransformer

+ (Class)transformedValueClass 
{ 
	return [NSNumber class]; 
}

+ (BOOL)allowsReverseTransformation 
{ 
	return NO; 
}

- (id)transformedValue:(id)value 
{
	if(value == nil)
		return nil;
	return [NSDate descriptionOfInterval:[value doubleValue] withSign:NO];
}

@end
