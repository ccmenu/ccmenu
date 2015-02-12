
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
        NSString *bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *sourceVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CCMSourceVersion"];
		[versionField setStringValue:[NSString stringWithFormat:@"%@ (%@)", bundleVersion, sourceVersion]];
	}
	[NSApp activateIgnoringOtherApps:YES];
	[aboutPanel makeKeyAndOrderFront:self];
}

@end
