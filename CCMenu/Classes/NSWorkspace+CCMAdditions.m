
#import "NSWorkspace+CCMAdditions.h"


@implementation NSWorkspace(CCMAdditions)

- (BOOL)openURLString:(NSString *)urlString;
{
    NSString *decodedUrl = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    if((decodedUrl == nil) || ([decodedUrl isEqualToString:urlString]))
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    return [self openURL:[NSURL URLWithString:urlString]];
}

@end