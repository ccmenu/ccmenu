
#import "CCMTimeIntervalTransformer.h"
#import "NSCalendarDate+CCMAdditions.h"

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
	return [NSCalendarDate descriptionOfInterval:[value doubleValue] withSign:NO];
}

@end
