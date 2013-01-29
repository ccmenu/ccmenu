
#import "CCMUserDefaultsManager.h"
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

- (NSInteger)pollInterval
{
	NSInteger interval = [userDefaults integerForKey:CCMDefaultsPollIntervalKey];
	NSAssert1(interval >= 5, @"Invalid poll interval; must be greater or equal 5 but is %ld.", interval);
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
	NSMutableArray *mutableList = [[[self projectList] mutableCopy] autorelease];
	[mutableList addObject:[self createEntryWithProject:projectName andURL:serverUrl]];
	[userDefaults setObject:mutableList forKey:CCMDefaultsProjectListKey];
}

- (BOOL)projectListContainsProject:(NSString *)projectName onServerWithURL:(NSString *)serverUrl
{
	return [[self projectList] containsObject:[self createEntryWithProject:projectName andURL:serverUrl]];
}

- (NSArray *)projectList
{
    NSArray *list = [userDefaults arrayForKey:CCMDefaultsProjectListKey];
    if(list != nil)
        return list;
    return [NSArray array];
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
    NSArray *list = [userDefaults arrayForKey:CCMDefaultsProjectListKey];
    if(list != nil)
    {
        urls = [[NSSet setWithArray:[[list collect] objectForKey:CCMDefaultsProjectEntryServerUrlKey]] allObjects];
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
