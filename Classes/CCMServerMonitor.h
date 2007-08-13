
#import <Cocoa/Cocoa.h>
#import "CCMConnection.h"


@interface CCMServerMonitor : NSObject 
{
	NSNotificationCenter	*notificationCenter;
	NSUserDefaults			*userDefaults;

	NSTimer					*timer;
	NSMutableDictionary		*repositories;
}

- (void)setNotificationCenter:(NSNotificationCenter *)center;
- (void)setUserDefaults:(NSUserDefaults *)defaults;

- (void)pollServers:(id)sender;

- (NSArray *)projects;

- (void)start;
- (void)stop;

@end

extern NSString *CCMProjectStatusUpdateNotification;

