
#import <Cocoa/Cocoa.h>
#import "CCMServerMonitor.h"
#import "CCMPreferencesController.h"
#import "CCMImageFactory.h"


@interface CCMAppController : NSObject
{
	IBOutlet CCMPreferencesController	*preferencesController;
	IBOutlet CCMImageFactory			*imageFactory;
	
	CCMServerMonitor	*monitor;
}

@end
