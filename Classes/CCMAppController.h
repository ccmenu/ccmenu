
#import <Cocoa/Cocoa.h>
#import "CCMServerMonitor.h"
#import "CCMStatusBarMenuController.h"
#import "CCMProjectWindowController.h"

@interface CCMAppController : NSObject 
{
	IBOutlet CCMProjectWindowController	*projectWindowController;
	IBOutlet CCMStatusBarMenuController	*statusMenuController;
	
	CCMServerMonitor					*monitor;
}

- (IBAction)checkStatus:(id)sender;

@end
