
#import "CCMServerMonitor.h"
#import "CCMProject.h"

NSString *CCMProjectStatusUpdateNotification = @"CCMProjectStatusUpdateNotification";


@implementation CCMServerMonitor

- (id)initWithConnection:(CCMConnection *)aConnection
{
	[super init];
	connection = [aConnection retain];
	projects = [[NSMutableDictionary alloc] init];
	return self;
}

- (void)dealloc
{
	[self stop];
	[connection release];
	[projects release];
	[super dealloc];	
}

- (void)start
{
	[self pollServer:nil];
	timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(pollServer:) userInfo:nil repeats:YES];
}

- (void)stop
{
	[timer invalidate];
	timer = nil;
}

- (void)pollServer:(id)sender
{
	NSEnumerator *infoEnum = [[connection getProjectInfos] objectEnumerator];
	NSDictionary *info;
	while((info = [infoEnum nextObject]) != nil)
	{
		NSString *projectName = [info objectForKey:@"name"];
		CCMProject *project = [projects objectForKey:projectName];
		if(project == nil)
		{
			project = [[[CCMProject alloc] initWithName:projectName] autorelease];
			[projects setObject:project forKey:projectName];
		}
		[project updateWithInfo:info];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:CCMProjectStatusUpdateNotification object:self];
}

- (NSArray *)projects
{
	return [projects allValues];
}

@end
