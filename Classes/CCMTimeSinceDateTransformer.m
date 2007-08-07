
#import "CCMTimeSinceDateTransformer.h"
#import "NSCalendarDate+CCMAdditions.h"


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
	return [[NSCalendarDate calendarDate] descriptionOfIntervalSinceDate:value];
}

@end
