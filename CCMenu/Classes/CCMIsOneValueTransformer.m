#import "CCMIsOneValueTransformer.h"

NSString *CCMIsOneTransformerName = @"CCMIsOneValueTransformer";


@implementation CCMIsOneValueTransformer

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
    return [NSNumber numberWithBool:((value != nil) && ([value intValue] == 1))];
}

@end
