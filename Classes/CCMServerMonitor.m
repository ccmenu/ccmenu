
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
	[center addObserver:self selector:@selector(defaultsChanged:) name:CCMPreferencesChangedNotification object:nil];
}

- (void)setUserDefaults:(NSUserDefaults *)defaults
{
	userDefaults = defaults;
}

- (void)setupRepositoriesFromDefaults
{
	NSArray *defaultsProjectList = [NSUnarchiver unarchiveObjectWithData:[userDefaults dataForKey:CCMDefaultsProjectListKey]];
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

- (void)defaultsChanged:(id)sender
{
	NSLog(@"DEFAULTS CHANGED, sender was %@", sender);
	[self stop];
	[self start];
}

- (void)pollServers:(id)sender
{
	NSLog(@"polling, sender was %@", sender);
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

- (void)start
{
	[self setupRepositoriesFromDefaults];
	int interval = [userDefaults integerForKey:CCMDefaultsPollIntervalKey];
	NSAssert1(interval >= 1, @"Invalid poll interval; must be greater or equal 1 but is %d.", interval);
	[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(pollServers:) userInfo:nil repeats:NO];
	timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(pollServers:) userInfo:nil repeats:YES];
}

- (void)stop
{
	[timer invalidate];
	timer = nil;
}



@end
