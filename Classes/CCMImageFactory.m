
#import "CCMImageFactory.h"
#import "CCMProject.h"


@implementation CCMImageFactory

- (NSImage *)imageForActivity:(NSString *)activity lastBuildStatus:(NSString *)status
{
	return [NSImage imageNamed:[self imageNameForActivity:activity lastBuildStatus:status]];
}

- (NSString *)imageNameForActivity:(NSString *)activity lastBuildStatus:(NSString *)status
{
	NSString *activityPart = [activity isEqualToString:CCMBuildingActivity] ? @"-building" : @"";
	return [NSString stringWithFormat:@"icon-%@%@.png", [status lowercaseString], activityPart];
}

- (NSImage *)pausedImage
{
	return [NSImage imageNamed:@"icon-pause.png"];
}

- (NSImage *)convertForMenuUse:(NSImage *)image
{
	NSImage *copy = [image copy];
	[copy setScalesWhenResized:NO];
	[copy setSize:NSMakeSize(15, 17)];
	return copy;
}

@end
