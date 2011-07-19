
#import <Cocoa/Cocoa.h>
#import "CCMConnection.h"
#import "CCMUserDefaultsManager.h"
#import "CCMBuildNotificationFactory.h"


@interface CCMServerMonitor : NSObject 
{
	IBOutlet CCMUserDefaultsManager		*defaultsManager;
	NSNotificationCenter				*notificationCenter;
	CCMBuildNotificationFactory			*notificationFactory;
	
	NSMutableArray						*serverConnectionPairs;
	NSTimer								*timer;
}

- (void)setDefaultsManager:(CCMUserDefaultsManager *)manager;
- (void)setNotificationCenter:(NSNotificationCenter *)center;
- (void)setNotificationFactory:(CCMBuildNotificationFactory *)factory;

- (NSArray *)servers;
- (NSArray *)projects;

- (void)start;
- (void)stop;

- (void)pollServers:(id)sender;

- (void)connection:(CCMConnection *)connection didReceiveServerStatus:(NSArray *)projectInfoList;
- (void)connection:(CCMConnection *)connection hadTemporaryError:(NSString *)errorString;

@end

extern NSString *CCMProjectStatusUpdateNotification;
