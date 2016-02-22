
#import "NSWorkspace+CCMAdditions.h"


@implementation NSWorkspace(CCMAdditions)

- (BOOL)openURLString:(NSString *)urlString
{
    NSString *decodedUrl = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    if((decodedUrl == nil) || ([decodedUrl isEqualToString:urlString]))
    {
        // if the string didn't contain any percent escapes we encode it, to be safe
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        // however, we undo the encoding of the fragment separator, which given the alternatives
        // seems the least terrible solution
        urlString = [urlString stringByReplacingOccurrencesOfString:@"%23" withString:@"#"];
    }

    return [self openURL:[NSURL URLWithString:urlString]];
}

@end