
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

- (void)start;
- (void)stop;

- (void)pollServers:(id)sender;

- (NSArray *)projects;

@end

extern NSString *CCMProjectStatusUpdateNotification;

