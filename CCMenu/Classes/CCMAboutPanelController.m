
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
#ifndef CCM_MAS_BUILD
        NSString *build = @"F";
#else
        NSString *build = @"A";
#endif
		[versionField setStringValue:[NSString stringWithFormat:@"%@ (%@%@)", shortVersion, version, build]];
	}
	[NSApp activateIgnoringOtherApps:YES];
	[aboutPanel makeKeyAndOrderFront:self];
}

@end
