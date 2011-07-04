
#import "CCMServerMonitor.h"
#import "CCMUserDefaultsManager.h"
#import "CCMServer.h"
#import "CCMProject.h"
#import "CCMConnection.h"
#import "CCMPreferencesController.h"
#import "NSArray+CCMAdditions.h"
#import <EDCommon/EDCommon.h>


NSString *CCMProjectStatusUpdateNotification = @"CCMProjectStatusUpdateNotification";


@implementation CCMServerMonitor

- (void)dealloc
{
	[self stop];
	[serverConnectionPairs release];
	[super dealloc];	
}

- (void)setDefaultsManager:(CCMUserDefaultsManager *)manager
{
	defaultsManager = manager;
}

- (void)setNotificationCenter:(NSNotificationCenter *)center
{
	notificationCenter = center;
	[center addObserver:self selector:@selector(defaultsChanged:) name:CCMPreferencesChangedNotification object:nil];
}

- (void)setNotificationFactory:(CCMBuildNotificationFactory *)factory
{
	notificationFactory = [factory retain];
}

- (NSArray *)servers
{
	return [[serverConnectionPairs collect] firstObject];
}

- (NSArray *)projects
{
	return [[[[self servers] collect] projects] flattenedArray];
}

- (NSArray *)connections
{
	return [[serverConnectionPairs collect] secondObject];
}

- (CCMServer *)serverForConnection:(CCMConnection *)connection
{
	NSEnumerator *pairEnum = [serverConnectionPairs objectEnumerator];
	EDObjectPair *pair;
	while((pair = [pairEnum nextObject]) != nil)
	{
		if([pair secondObject] == connection)
			return [pair firstObject];
	}
	return nil;
}

- (void)setupFromUserDefaults
{
	[[[self connections] each] cancelStatusRequest];
	[serverConnectionPairs release];
	
	serverConnectionPairs = [[NSMutableArray array] retain];
	NSEnumerator *serverEnum = [[defaultsManager servers] objectEnumerator];
	CCMServer *server;
	while((server = [serverEnum nextObject]) != nil)
	{
		CCMConnection *connection = [[[CCMConnection alloc] initWithURL:[server url]] autorelease];
		[connection setDelegate:self];
		EDObjectPair *pair = [EDObjectPair pairWithObjects:server :connection];
		[serverConnectionPairs addObject:pair];
	}
}

- (void)start
{
	[self setupFromUserDefaults];
	[notificationCenter postNotificationName:CCMProjectStatusUpdateNotification object:self];
	if([[self connections] count] == 0)
		return;
	int interval = [defaultsManager pollInterval];
	[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(pollServers:) userInfo:nil repeats:NO];
	timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(pollServers:) userInfo:nil repeats:YES];
}

- (void)stop
{
	[timer invalidate];
	timer = nil;
}

- (void)pollServers:(id)sender
{
	[[[self connections] each] requestServerStatus];
}

- (void)defaultsChanged:(id)sender
{
	[self stop];
	[self start];
}

- (void)connection:(CCMConnection *)connection didReceiveServerStatus:(NSArray *)projectInfoList
{
	CCMServer *server = [self serverForConnection:connection];
	if(server == nil)
		return;
    
    NSEnumerator *projectEnum = [[server projects] objectEnumerator];
    CCMProject *project;
    while((project = [projectEnum nextObject]) != nil)
    {
        [project updateWithInfo:[NSDictionary dictionaryWithObject:@"No project information provided by server." forKey:@"errorString"]]; 
    }
	
	NSEnumerator *projectInfoEnum = [projectInfoList objectEnumerator];
	NSDictionary *projectInfo;
	while((projectInfo = [projectInfoEnum nextObject]) != nil)
	{
		CCMProject *project = [server projectNamed:[projectInfo objectForKey:@"name"]];
		if(project == nil)
			continue;
		NSNotification *notification = [notificationFactory buildCompleteNotificationForOldProjectInfo:[project info] andNewProjectInfo:projectInfo];
		if(notification != nil)
			[notificationCenter postNotification:notification];
		[server updateWithProjectInfo:projectInfo];
	}
	
	[notificationCenter postNotificationName:CCMProjectStatusUpdateNotification object:self];
}

- (void)connection:(CCMConnection *)connection hadTemporaryError:(NSString *)errorString
{	
	CCMServer *server = [self serverForConnection:connection];
	if(server == nil)
		return;
	
	NSDictionary *projectErrorInfo = [NSDictionary dictionaryWithObject:errorString forKey:@"errorString"];
	[[[server projects] each] updateWithInfo:projectErrorInfo];
	
	[notificationCenter postNotificationName:CCMProjectStatusUpdateNotification object:self];
}

@end
