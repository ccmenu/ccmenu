
#import "CCMAboutPanelController.h"

@implementation CCMAboutPanelController

- (void)showWindow:(id)sender
{
	if(aboutPanel == nil)
	{
        NSArray *toplevelObjects = nil;
		[[NSBundle mainBundle] loadNibNamed:@"About" owner:self topLevelObjects:&toplevelObjects];
        [toplevelObjects retain];
		[aboutPanel center];
        NSString *shortVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
		[versionField setStringValue:[NSString stringWithFormat:@"%@ (%@)", shortVersion, version]];
	}
	[NSApp activateIgnoringOtherApps:YES];
	[aboutPanel makeKeyAndOrderFront:self];
}

@end
