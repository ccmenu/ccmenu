
#import <Cocoa/Cocoa.h>
#import "CCMPreferencesController.h"
#import "CCMServerMonitor.h"
#import "CCMImageFactory.h"
#import "CCMUserNotificationHandler.h"


@interface CCMAppController : NSObject
{
	IBOutlet CCMPreferencesController	*preferencesController;
	IBOutlet CCMImageFactory			*imageFactory;
	IBOutlet CCMServerMonitor			*serverMonitor;
    IBOutlet CCMUserNotificationHandler *userNotificationHandler;
}

@end
