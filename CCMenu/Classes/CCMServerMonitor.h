
#import <Cocoa/Cocoa.h>
#import "CCMConnection.h"
#import "CCMUserDefaultsManager.h"
#import "CCMBuildNotificationFactory.h"


@interface CCMServerMonitor : NSObject <CCMConnectionDelegate>
{
	IBOutlet CCMUserDefaultsManager		*defaultsManager;
	NSNotificationCenter				*notificationCenter;
	CCMBuildNotificationFactory			*notificationFactory;

	NSMutableArray                      *connections;
    NSMutableArray                      *projects;
    
	NSMutableArray						*serverConnectionPairs;
	NSTimer								*timer;
}

- (void)setDefaultsManager:(CCMUserDefaultsManager *)manager;
- (void)setNotificationCenter:(NSNotificationCenter *)center;
- (void)setNotificationFactory:(CCMBuildNotificationFactory *)factory;

- (void)setupFromUserDefaults;

- (NSArray *)projects;
- (NSArray *)connections;

- (void)start;
- (void)stop;

- (IBAction)pollServers:(id)sender;

@end

extern NSString *CCMProjectStatusUpdateNotification;
