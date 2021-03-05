
#import "CCMServerMonitor.h"
#import "CCMPreferencesController.h"
#import "NSArray+CCMAdditions.h"


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

- (NSArray *)projects
{
	return projects;
}

- (NSArray *)connections
{
	return connections;
}

- (NSMutableDictionary *)projectsByNameForConnection:(CCMConnection *)aConnection
{
    NSMutableDictionary *projectsByName = [NSMutableDictionary dictionary];
    for(CCMProject *p in projects)
    {
        if([[p serverURL] isEqual:[aConnection feedURL]])
            [projectsByName setObject:p forKey:[p name]];
    }
    return projectsByName;
}

- (void)setupFromUserDefaults
{
    [[connections each] cancelRequest];

	[self setupProjectsFromUserDefaults];
	[self setupConnections];
}

- (void)setupProjectsFromUserDefaults
{
	NSArray *previousProjects = [projects autorelease];
	projects = [[NSMutableArray alloc] init];
	for(CCMProject *p in [defaultsManager projectList])
	{
		if((previousProjects != nil) && ([previousProjects containsObject:p]))
		{
			CCMProject *existing = [previousProjects objectAtIndex:[previousProjects indexOfObject:p]];
			if(![[p displayName] isEqualToString:[p name]])
				[existing setDisplayName:[p displayName]];
            else
                [existing setDisplayName:nil];
			[projects addObject:existing];
		}
		else
		{
			[projects addObject:p];
		}
	}
}

- (void)setupConnections
{
	[connections release];
	connections = [[NSMutableArray alloc] init];

    NSSet *urlSet = [NSSet setWithArray:(id)[[projects collect] serverURL]];
	for(NSURL *url in urlSet)
    {
		CCMConnection *c = [[[CCMConnection alloc] initWithFeedURL:url] autorelease];
		[c setDelegate:self];
        [connections addObject:c];
    }
}


- (void)start
{
	[self setupFromUserDefaults];
	[notificationCenter postNotificationName:CCMProjectStatusUpdateNotification object:self];
	if([[self connections] count] == 0)
		return;
	[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(pollServers:) userInfo:nil repeats:NO];
	NSInteger interval = [defaultsManager pollInterval];
	timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(pollServers:) userInfo:nil repeats:YES];
}

- (void)stop
{
	[timer invalidate];
	timer = nil;
}

- (void)defaultsChanged:(id)sender
{
	[self stop];
	[self start];
}

- (void)pollServers:(id)sender
{
	[[[self connections] each] requestServerStatus];
}

- (void)connection:(CCMConnection *)connection didReceiveServerStatus:(NSArray *)projectInfoList
{
    NSMutableDictionary *projectsByName = [self projectsByNameForConnection:connection];
    for(NSDictionary *projectInfo in projectInfoList)
	{
		CCMProject *project = [projectsByName objectForKey:[projectInfo objectForKey:@"name"]];
		if(project == nil)
			continue;
        [projectsByName removeObjectForKey:[projectInfo objectForKey:@"name"]];
        CCMProjectStatus *oldStatus = [[[project status] retain] autorelease];
		[project updateWithInfo:projectInfo];
		NSNotification *notification = [notificationFactory notificationForProject:project withOldStatus:oldStatus];
		if(notification != nil)
			[notificationCenter postNotification:notification];
	}
 	NSDictionary *projectErrorInfo = [NSDictionary dictionaryWithObject:@"The server did not provide information for this project. If the project has been renamed on the server you have to remove this project and add it with the new name." forKey:@"errorString"];
	[[[projectsByName allValues] each] updateWithInfo:projectErrorInfo];
    
	[notificationCenter postNotificationName:CCMProjectStatusUpdateNotification object:self];
}

- (void)connection:(CCMConnection *)connection hadTemporaryError:(NSString *)errorString
{	
    NSMutableDictionary *projectsByName = [self projectsByNameForConnection:connection];
	NSDictionary *projectErrorInfo = [NSDictionary dictionaryWithObject:errorString forKey:@"errorString"];
	[[[projectsByName allValues] each] updateWithInfo:projectErrorInfo];
	
	[notificationCenter postNotificationName:CCMProjectStatusUpdateNotification object:self];
}

@end
