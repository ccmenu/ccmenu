
#import "CCMServerMonitor.h"

NSString *CCMProjectStatusUpdateNotification = @"CCMProjectStatusUpdateNotification";


@implementation CCMServerMonitor

- (id)initWithConnection:(CCMConnection *)aConnection
{
	[super init];
	connection = [aConnection retain];
	return self;
}

- (void)dealloc
{
	[self stop];
	[connection release];
	[projectInfos release];
	[super dealloc];	
}

- (void)start
{
	[self pollServer:nil];
	timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(pollServer:) userInfo:nil repeats:YES];
}

- (void)stop
{
	[timer invalidate];
	timer = nil;
}

- (void)pollServer:(id)sender
{
	NSArray *newProjectInfos = [connection getProjectInfos];
	[projectInfos autorelease];
	projectInfos = [newProjectInfos retain];
	[[NSNotificationCenter defaultCenter] postNotificationName:CCMProjectStatusUpdateNotification object:self];
}

- (NSArray *)getProjectInfos
{
	return projectInfos;
}

@end
