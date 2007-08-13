
#import <Cocoa/Cocoa.h>
#import "CCMConnection.h"


@interface CCMServerMonitor : NSObject 
{
	CCMConnection			*connection;
	NSNotificationCenter	*notificationCenter;

	NSTimer					*timer;
	NSMutableDictionary		*projects;
}

- (id)initWithConnection:(CCMConnection *)aConnection andProjects:(NSArray *)projectNames;

- (void)setNotificationCenter:(NSNotificationCenter *)center;

- (void)start;
- (void)stop;

- (void)pollServer:(id)sender;

- (NSArray *)projects;

@end

extern NSString *CCMProjectStatusUpdateNotification;
extern NSString *CCMBuildCompleteNotification;

extern NSString *CCMSuccessfulBuild;
extern NSString *CCMFixedBuild;
extern NSString *CCMBrokenBuild;
extern NSString *CCMStillFailingBuild;
