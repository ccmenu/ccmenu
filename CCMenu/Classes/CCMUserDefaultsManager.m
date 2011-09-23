
#import "CCMUserDefaultsManager.h"
#import "CCMServer.h"
#import "NSArray+CCMAdditions.h"
#import <EDCommon/EDCommon.h>

NSString *CCMDefaultsProjectListKey = @"Projects";
NSString *CCMDefaultsProjectEntryNameKey = @"projectName";
NSString *CCMDefaultsProjectEntryServerUrlKey = @"serverUrl";
NSString *CCMDefaultsPollIntervalKey = @"PollInterval";
NSString *CCMDefaultsServerUrlHistoryKey = @"ServerHistory";


@implementation CCMUserDefaultsManager

- (void)awakeFromNib
{
	userDefaults = [NSUserDefaults standardUserDefaults];
    [self convertDefaultsIfNecessary];
}

- (int)pollInterval
{
	int interval = [userDefaults integerForKey:CCMDefaultsPollIntervalKey];
	NSAssert1(interval >= 5, @"Invalid poll interval; must be greater or equal 5 but is %d.", interval);
	return interval;
}

- (NSDictionary *)createEntryWithProject:(NSString *)projectName andURL:(NSString *)serverUrl
{
	return [NSDictionary dictionaryWithObjectsAndKeys: projectName, CCMDefaultsProjectEntryNameKey, 
		serverUrl, CCMDefaultsProjectEntryServerUrlKey, nil];	
}

- (void)addProject:(NSString *)projectName onServerWithURL:(NSString *)serverUrl
{
	if([self projectListContainsProject:projectName onServerWithURL:serverUrl])
		return;
	NSMutableArray *mutableList = [[[self projectListEntries] mutableCopy] autorelease];
	[mutableList addObject:[self createEntryWithProject:projectName andURL:serverUrl]];
	[userDefaults setObject:mutableList forKey:CCMDefaultsProjectListKey];
}

- (BOOL)projectListContainsProject:(NSString *)projectName onServerWithURL:(NSString *)serverUrl
{
	return [[self projectListEntries] containsObject:[self createEntryWithProject:projectName andURL:serverUrl]];
}

- (NSArray *)projectListEntries
{
    NSArray *list = [userDefaults arrayForKey:CCMDefaultsProjectListKey];
    if(list != nil)
        return list;
    return [NSArray array];
}

- (NSArray *)servers
{
	NSMutableDictionary *projectNamesByServer = [NSMutableDictionary dictionary];
	for(NSDictionary *projectListEntry in [self projectListEntries])
	{
		NSString *urlString = [projectListEntry objectForKey:CCMDefaultsProjectEntryServerUrlKey];
		NSString *projectName = [projectListEntry objectForKey:CCMDefaultsProjectEntryNameKey];
		if((urlString != nil) && (projectName != nil))
			[projectNamesByServer addObject:projectName toArrayForKey:urlString];
	}
	
	NSMutableArray *servers = [NSMutableArray array];
	for(NSString *urlString in projectNamesByServer)
	{
		NSURL *url = [NSURL URLWithString:urlString];
		NSArray *projectNames = [projectNamesByServer objectForKey:urlString];
		CCMServer *server = [[[CCMServer alloc] initWithURL:url andProjectNames:projectNames] autorelease];
		[servers addObject:server];
	}
	return servers;
}

- (void)addServerURLToHistory:(NSString *)serverUrl
{
	NSArray *list = [self serverURLHistory];
	if([list containsObject:serverUrl])
		return;
	list = [list arrayByAddingObject:serverUrl];
	[userDefaults setObject:list forKey:CCMDefaultsServerUrlHistoryKey];
}

- (NSArray *)serverURLHistory
{
	NSArray *urls = [userDefaults arrayForKey:CCMDefaultsServerUrlHistoryKey];
	if(urls != nil)
	{
		return urls;
	}
	NSArray *servers = [self servers];
	if([servers count] > 0)
	{
		urls = (id)[[(id)[[servers collect] url] collect] absoluteString];
		[userDefaults setObject:urls forKey:CCMDefaultsServerUrlHistoryKey];
		return urls;
	}
	return [NSArray array];
}

- (void)convertDefaultsIfNecessary
{
    NSArray *list = [userDefaults arrayForKey:CCMDefaultsProjectListKey];
    NSData *data = [userDefaults dataForKey:CCMDefaultsProjectListKey];
    if((list == nil) && (data != nil))
    {
        [userDefaults setObject:[NSUnarchiver unarchiveObjectWithData:data] forKey:CCMDefaultsProjectListKey];
    }
}


@end
