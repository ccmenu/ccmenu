
#import <Cocoa/Cocoa.h>
#import "CCMConnection.h"


@interface CCMServerMonitor : NSObject 
{
	CCMConnection		*connection;
	NSTimer				*timer;
	NSMutableDictionary	*projects;
}

- (id)initWithConnection:(CCMConnection *)aConnection;

- (void)start;
- (void)stop;

- (void)pollServer:(id)sender;

- (NSArray *)projects;

@end

extern NSString *CCMProjectStatusUpdateNotification;
