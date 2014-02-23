
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
#ifndef CCM_MAS_BUILD
    [updateNoteField setStringValue:NSLocalizedString(@"Checking for update...", "For note in about panel")];
    [updateInstallButton setHidden:YES];
    [updater checkForUpdateInformation];
#endif
	[NSApp activateIgnoringOtherApps:YES];
	[aboutPanel makeKeyAndOrderFront:self];
}

#ifndef CCM_MAS_BUILD
- (IBAction)checkForUpdateNow:(id)sender
{
    [updater checkForUpdates:sender];
}

- (void)updater:(SUUpdater *)updater didFindValidUpdate:(SUAppcastItem *)update
{
    [updateInstallButton setHidden:NO];
    [updateNoteField setStringValue:NSLocalizedString(@"An update is available", "For note in about panel")];
}

- (void)updaterDidNotFindUpdate:(SUUpdater *)update
{
    [updateNoteField setStringValue:NSLocalizedString(@"CCMenu is up to date", "For note in about panel")];
}

#endif

@end
