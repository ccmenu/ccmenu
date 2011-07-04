
#import "CCMImageFactory.h"
#import "CCMProject.h"


@implementation CCMImageFactory

- (NSImage *)imageNamed:(NSString *)name
{
	NSImage *image = [NSImage imageNamed:name];
	if(image == nil)
	{
		// This is a hack to make the unit tests work when run from otool, in which case imageNamed: doesn't work
		NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"Images/%@", name]];
		image = [[[NSImage alloc] initWithContentsOfURL:url] autorelease];
		[image setName:[name substringToIndex:[name length] - [[name pathExtension] length] - 1]];
	}
	return image;	
}

- (NSImage *)imageForActivity:(NSString *)activity lastBuildStatus:(NSString *)status
{
	if(status == nil)
		return [self imageForUnavailableServer];
	activity = [activity isEqualToString:CCMBuildingActivity] ? @"-building" : @"";
	if(![status isEqualToString:CCMSuccessStatus])
		status = CCMFailedStatus;
	status = [status lowercaseString];
	NSString *name = [NSString stringWithFormat:@"icon-%@%@.png", status, activity];
	return [self imageNamed:name];
}

- (NSImage *)imageForUnavailableServer
{
	return [self imageNamed:@"icon-inactive.png"];
}

- (NSImage *)convertForMenuUse:(NSImage *)originalImage
{
	NSString *name = [NSString stringWithFormat:@"%@-menu", [originalImage name]];
	NSImage *menuImage = [NSImage imageNamed:name];
	if(menuImage == nil)
	{
		menuImage = [[originalImage copy] autorelease];
		[menuImage setScalesWhenResized:NO];
		[menuImage setSize:NSMakeSize(15, 17)];
		[menuImage setName:name];
	}
	return menuImage;
}

@end
