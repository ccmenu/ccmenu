
#import "CCMImageFactory.h"
#import "CCMProject.h"
#import "CCMProjectStatus.h"


@implementation CCMImageFactory

- (NSImage *)imageNamed:(NSString *)name
{
	NSImage *image = [NSImage imageNamed:name];
	if(image == nil)
	{
		// This is a hack to make the unit tests work when run from otool, in which case imageNamed: doesn't work
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        image = [[[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:name]] autorelease];
		[image setName:name];
	}
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"UseColorInMenuBar"] == NO) {
        image.template = YES;
    } else {
        image.template = NO;
    }
	return image;
}

- (NSImage *)imageForStatus:(CCMProjectStatus *)status
{
    if(status == nil)
        return [self imageForUnavailableServer];

    NSString *name = @"";
    if([[status activity] isEqualToString:@"Building"])
    {
        if([status buildDidFail])
            name = @"icon-failure-building";
        else
            name = @"icon-success-building";
    }
    else
    {
        if([status buildWasSuccessful])
            name = @"icon-success";
        else if([status buildDidFail])
            name = @"icon-failure";
        else if([[status lastBuildStatus] isEqualToString:@"Unknown"])
            name = @"icon-pause";
        else
            name = @"icon-inactive";
    }
    return [self imageNamed:name];
}

- (NSImage *)imageForUnavailableServer
{
	return [self imageNamed:@"icon-inactive"];
}

- (NSImage *)convertForMenuUse:(NSImage *)originalImage
{
    NSString *name = [NSString stringWithFormat:@"%@%@", [originalImage name], @"-menu"];
    NSImage *newImage = [NSImage imageNamed:name];
    if(newImage == nil)
    {
        NSSize size = NSMakeSize([originalImage size].width, [originalImage size].height + 2);
        newImage = [NSImage imageWithSize:size flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
            [originalImage drawAtPoint:NSMakePoint(0, 0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
            return YES;
        }];
        [newImage setName:name];
    }
    return newImage;
}

@end
