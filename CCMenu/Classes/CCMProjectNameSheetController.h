
#import <Cocoa/Cocoa.h>
#import "CCMUserDefaultsManager.h"


@interface CCMProjectNameSheetController : NSObject
{
    IBOutlet CCMUserDefaultsManager	*defaultsManager;

    IBOutlet NSPanel				*projectNameSheet;
    IBOutlet NSTextField            *originalNameField;
    IBOutlet NSTextField            *displayNameField;
}

- (void)beginSheetWithProject:(NSDictionary *)aProject forWindow:(NSWindow *)aWindow;

- (IBAction)closeSheet:(id)sender;

@end
