
#import <Cocoa/Cocoa.h>
#import "CCMConnection.h"


@interface CCMProjectRepository : NSObject 
{
	CCMConnection			*connection;
	NSNotificationCenter	*notificationCenter;
	NSMutableDictionary		*projects;
}

- (id)initWithConnection:(CCMConnection *)aConnection andProjects:(NSArray *)projectNames;

- (void)setNotificationCenter:(NSNotificationCenter *)center;

- (void)pollServer;

- (NSArray *)projects;

@end


extern NSString *CCMBuildCompleteNotification;

extern NSString *CCMSuccessfulBuild;
extern NSString *CCMFixedBuild;
extern NSString *CCMBrokenBuild;
extern NSString *CCMStillFailingBuild;
