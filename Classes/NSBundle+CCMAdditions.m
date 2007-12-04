
#import "NSBundle+CCMAdditions.h"


@implementation NSBundle(CCMAdditions)

- (NSString *)bundleVersionString
{
	NSDictionary *info = [self infoDictionary];
	return [NSString stringWithFormat:@"%@ (%@)", 
			[info objectForKey:@"CFBundleShortVersionString"], [info objectForKey:@"CFBundleVersion"]];
}

@end
