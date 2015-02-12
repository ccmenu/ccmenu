
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
        NSString *sourceVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CCMSourceVersion"];
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
		[versionField setStringValue:[NSString stringWithFormat:@"%@.%@", version, sourceVersion]];
	}
	[NSApp activateIgnoringOtherApps:YES];
	[aboutPanel makeKeyAndOrderFront:self];
}

@end
