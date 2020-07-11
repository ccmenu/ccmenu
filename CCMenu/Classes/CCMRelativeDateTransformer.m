
#import "CCMRelativeDateTransformer.h"
#import "NSDate+CCMAdditions.h"

NSString *CCMRelativeDateTransformerName = @"CCMRelativeDateTransformer";


@implementation CCMRelativeDateTransformer

+ (Class)transformedValueClass 
{ 
	return [NSDate class]; 
}

+ (BOOL)allowsReverseTransformation 
{ 
	return NO; 
}

- (id)transformedValue:(id)value 
{
	if(value == nil)
		return nil;
	return [value descriptionRelativeToNow];
}

@end
