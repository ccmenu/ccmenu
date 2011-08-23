
#import "CCMTimeSinceDateTransformer.h"
#import "NSCalendarDate+CCMAdditions.h"

NSString *CCMTimeSinceDateTransformerName = @"CCMTimeSinceDateTransformer";


@implementation CCMTimeSinceDateTransformer

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
