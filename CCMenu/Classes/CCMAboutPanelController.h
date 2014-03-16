
#import <Cocoa/Cocoa.h>


@interface CCMAboutPanelController : NSObject
{
    IBOutlet NSPanel        *aboutPanel;
    IBOutlet NSTextField	*versionField;
}

- (IBAction)showWindow:(id)sender;

@end
