
#import <Cocoa/Cocoa.h>
#import "CCMConnection.h"
#import "CCMBuildNotificationFactory.h"


@interface CCMServerMonitor : NSObject 
{
	NSUserDefaults				*userDefaults;
	NSNotificationCenter		*notificationCenter;
	CCMBuildNotificationFactory	*notificationFactory;
	
	NSMutableArray				*serverConnectionPairs;
	NSTimer						*timer;
}

- (void)setUserDefaults:(NSUserDefaults *)defaults;
- (void)setNotificationCenter:(NSNotificationCenter *)center;
- (void)setNotificationFactory:(CCMBuildNotificationFactory *)factory;

- (NSArray *)servers;
- (NSArray *)projects;

- (void)start;
- (void)stop;

- (void)pollServers:(id)sender;

@end

extern NSString *CCMProjectStatusUpdateNotification;
