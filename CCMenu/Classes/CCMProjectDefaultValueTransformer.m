
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
    if(value == nil)
        return nil;
    
    NSString *name = [value objectForKey:@"projectName"];
    NSString *displayName = [value objectForKey:@"displayName"];
    if(displayName != nil)
        name = [NSString stringWithFormat:@"%@ (%@)", name, displayName];
    NSDictionary *nameAttrs = @{NSFontAttributeName: [NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]]};
    NSString *url = [value objectForKey:@"serverUrl"];
    NSDictionary *urlAttrs = @{ NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]],
                                NSForegroundColorAttributeName: [NSColor disabledControlTextColor]};

    NSMutableAttributedString *result = [[[NSMutableAttributedString alloc] init] autorelease];
    [result appendAttributedString:[[[NSAttributedString alloc] initWithString:name attributes:nameAttrs] autorelease]];
    [result appendAttributedString:[[[NSAttributedString alloc] initWithString:@"\n"] autorelease]];
    [result appendAttributedString:[[[NSAttributedString alloc] initWithString:url attributes:urlAttrs] autorelease]];
    return result;
}

@end




