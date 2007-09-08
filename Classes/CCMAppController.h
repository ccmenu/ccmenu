
#import <Cocoa/Cocoa.h>
#import "CCMPreferencesController.h"
#import "CCMServerMonitor.h"
#import "CCMGrowlAdaptor.h"
#import "CCMImageFactory.h"


@interface CCMAppController : NSObject
{
	IBOutlet CCMPreferencesController	*preferencesController;
	IBOutlet CCMImageFactory			*imageFactory;
	IBOutlet CCMServerMonitor			*serverMonitor;
	IBOutlet CCMGrowlAdaptor			*growlAdaptor;
}

@end
