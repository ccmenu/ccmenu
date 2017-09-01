
#import "CCMProjectDefaultValueTransformer.h"

NSString *CCMProjectDefaultValueTransformerName = @"CCMProjectDefaultValueTransformer";


@implementation CCMProjectDefaultValueTransformer

+ (Class)transformedValueClass
{
    return [NSAttributedString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
	return [self transformedValue:value isSelected:NO];
}

- (id)transformedValue:(id)value isSelected:(BOOL)isSelected
{
    if(value == nil)
        return nil;

	NSString *name = [value objectForKey:@"projectName"];
    NSString *displayName = [value objectForKey:@"displayName"];
    if(displayName != nil)
        name = [NSString stringWithFormat:@"%@ (%@)", name, displayName];
	NSColor *nameColor = isSelected ? [NSColor alternateSelectedControlTextColor] : [NSColor controlTextColor];
    NSDictionary *nameAttrs = @{NSFontAttributeName: [NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]],
								NSForegroundColorAttributeName: nameColor};
    NSString *url = [value objectForKey:@"serverUrl"];
	NSColor *urlColor = isSelected ? [NSColor selectedTextColor] : [NSColor disabledControlTextColor];
    NSDictionary *urlAttrs = @{ NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]],
                                NSForegroundColorAttributeName: urlColor};

    NSMutableAttributedString *result = [[[NSMutableAttributedString alloc] init] autorelease];
    [result appendAttributedString:[[[NSAttributedString alloc] initWithString:name attributes:nameAttrs] autorelease]];
    [result appendAttributedString:[[[NSAttributedString alloc] initWithString:@"\n"] autorelease]];
    [result appendAttributedString:[[[NSAttributedString alloc] initWithString:url attributes:urlAttrs] autorelease]];
    return result;
}

@end




