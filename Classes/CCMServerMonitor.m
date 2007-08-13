
#import "CCMServerMonitor.h"
#import "CCMPreferencesController.h"
#import "CCMProjectRepository.h"
#import "CCMConnection.h"
#import "CCMProject.h"

NSString *CCMProjectStatusUpdateNotification = @"CCMProjectStatusUpdateNotification";


@implementation CCMServerMonitor

- (void)dealloc
{
	[self stop];
	[repositories release];
	[super dealloc];	
}

- (void)setNotificationCenter:(NSNotificationCenter *)center
{
	notificationCenter = center;
}

- (void)setUserDefaults:(NSUserDefaults *)defaults
{
	userDefaults = defaults;
}

- (void)setupRepositories:(NSArray *)defaultsProjectList
{
	NSMutableDictionary *projectNamesByServer = [NSMutableDictionary dictionary];
	NSEnumerator *defaultsProjectEntryEnum = [defaultsProjectList objectEnumerator];
	NSDictionary *defaultsProjectEntry;
	while((defaultsProjectEntry = [defaultsProjectEntryEnum nextObject]) != nil)
	{
		NSString *server = [defaultsProjectEntry objectForKey:CCMDefaultsProjectEntryServerUrlKey];
		NSMutableArray *projectNames = [projectNamesByServer objectForKey:server];
		if(projectNames == nil)
		{
			projectNames = [NSMutableArray array];
			[projectNamesByServer setObject:projectNames forKey:server];
		}
		[projectNames addObject:[defaultsProjectEntry objectForKey:CCMDefaultsProjectEntryNameKey]];
	}

	[repositories release];
	repositories = [[NSMutableDictionary dictionary] retain];
	NSEnumerator *serverEnum = [projectNamesByServer keyEnumerator];
	NSString *server;
	while((server = [serverEnum nextObject]) != nil)
	{
		CCMConnection *connection = [[[CCMConnection alloc] initWithURL:[NSURL URLWithString:server]] autorelease];
		NSArray *projectNames = [projectNamesByServer objectForKey:server];
		CCMProjectRepository *repo = [[[CCMProjectRepository alloc] initWithConnection:connection andProjects:projectNames] autorelease];
		[repositories setObject:repo forKey:server];
	}
}

- (void)start
{
	[self setupRepositories:[NSUnarchiver unarchiveObjectWithData:[userDefaults dataForKey:CCMDefaultsProjectListKey]]];
	timer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(pollServers:) userInfo:nil repeats:YES];
}

- (void)stop
{
	[timer invalidate];
	timer = nil;
}

- (void)pollServers:(id)sender
{
	NSEnumerator *repositoryEnum = [[repositories allValues] objectEnumerator];
	CCMProjectRepository *repository;
	while((repository = [repositoryEnum nextObject]) != nil)
		[repository pollServer];
	[notificationCenter postNotificationName:CCMProjectStatusUpdateNotification object:self userInfo:nil];
}

- (NSArray *)projects
{
	NSMutableArray *projects = [NSMutableArray array];
	NSEnumerator *repositoryEnum = [[repositories allValues] objectEnumerator];
	CCMProjectRepository *repository;
	while((repository = [repositoryEnum nextObject]) != nil)
		[projects addObjectsFromArray:[repository projects]];
	return projects;
}



@end
