
#import <Cocoa/Cocoa.h>
#import "CCMConnection.h"


@interface CCMServerMonitor : NSObject 
{
	CCMConnection	*connection;
	NSTimer			*timer;
	NSArray			*projectInfos;
}

- (id)initWithConnection:(CCMConnection *)aConnection;

- (void)start;
- (void)stop;

- (void)pollServer:(id)sender;

- (NSArray *)getProjectInfos;

@end

extern NSString *CCMProjectStatusUpdateNotification;
