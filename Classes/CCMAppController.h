
#import <Cocoa/Cocoa.h>
#import "CCMServerMonitor.h"
#import "CCMStatusBarMenuController.h"
#import "CCMProjectWindowController.h"
#import "CCMImageFactory.h"


@interface CCMAppController : NSObject
{
	IBOutlet CCMProjectWindowController	*projectWindowController;
	IBOutlet CCMStatusBarMenuController	*statusBarMenuController;
	IBOutlet CCMImageFactory			*imageFactory;
	
	CCMServerMonitor	*monitor;
}

@end
