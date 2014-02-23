
#import <Cocoa/Cocoa.h>
#import <Sparkle/Sparkle.h>


@interface CCMAboutPanelController : NSObject
{
#ifndef CCM_MAS_BUILD
	IBOutlet SUUpdater		*updater;
#endif
    IBOutlet NSPanel        *aboutPanel;
    IBOutlet NSTextField	*versionField;
}

- (IBAction)showWindow:(id)sender;

#ifndef CCM_MAS_BUILD
- (IBAction)checkForUpdateNow:(id)sender;
#endif

@end
