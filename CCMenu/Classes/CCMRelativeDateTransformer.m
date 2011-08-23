
#import "CCMRelativeDateTransformer.h"
#import "NSCalendarDate+CCMAdditions.h"

NSString *CCMRelativeDateTransformerName = @"CCMRelativeDateTransformer";


@implementation CCMRelativeDateTransformer

+ (Class)transformedValueClass 
{ 
	return [NSCalendarDate class]; 
}

+ (BOOL)allowsReverseTransformation 
{ 
	return NO; 
}

- (id)transformedValue:(id)value 
{
	if(value == nil)
		return nil;
	return [[NSCalendarDate calendarDate] relativeDescriptionOfPastDate:value];
}

@end
