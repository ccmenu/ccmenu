
#import "CCMUserDefaultsManager.h"
#import "CCMServer.h"
#import <EDCommon/EDCommon.h>

NSString *CCMDefaultsProjectListKey = @"Projects";
NSString *CCMDefaultsProjectEntryNameKey = @"projectName";
NSString *CCMDefaultsProjectEntryServerUrlKey = @"serverUrl";
NSString *CCMDefaultsPollIntervalKey = @"PollInterval";


@implementation CCMUserDefaultsManager

- (void)awakeFromNib
{
	userDefaults = [NSUserDefaults standardUserDefaults];
}

- (int)pollInterval
{
	int interval = [userDefaults integerForKey:CCMDefaultsPollIntervalKey];
	NSAssert1(interval >= 5, @"Invalid poll interval; must be greater or equal 1 but is %d.", interval);
	return interval;
}

- (void)updateWithProjectInfos:(NSArray *)projectInfos withServerURL:(NSURL *)serverUrl
{
	NSMutableArray *mutableList = [[[self projectListEntries] mutableCopy] autorelease];
	
	NSEnumerator *projectInfoEnum = [projectInfos objectEnumerator];
	NSDictionary *projectInfo;
	while((projectInfo = [projectInfoEnum nextObject]) != nil)
	{
		NSDictionary *projectListEntry = [NSDictionary dictionaryWithObjectsAndKeys:
			[projectInfo objectForKey:@"name"], CCMDefaultsProjectEntryNameKey, 
			[serverUrl absoluteString], CCMDefaultsProjectEntryServerUrlKey, nil];
		if(![mutableList containsObject:projectListEntry])
			[mutableList addObject:projectListEntry];
	}
	NSData *data = [NSArchiver archivedDataWithRootObject:[mutableList copy]];
	[userDefaults setObject:data forKey:CCMDefaultsProjectListKey];
}

- (NSArray *)projectListEntries
{
	NSData *defaultsData = [userDefaults dataForKey:CCMDefaultsProjectListKey];
	if(defaultsData == nil)
		return [NSArray array];
	return [NSUnarchiver unarchiveObjectWithData:defaultsData];
}

- (NSArray *)servers
{
	NSMutableDictionary *projectNamesByServer = [NSMutableDictionary dictionary];
	NSEnumerator *projectListEnum = [[self projectListEntries] objectEnumerator];
	NSDictionary *projectListEntry;
	while((projectListEntry = [projectListEnum nextObject]) != nil)
	{
		NSString *urlString = [projectListEntry objectForKey:CCMDefaultsProjectEntryServerUrlKey];
		NSString *projectName = [projectListEntry objectForKey:CCMDefaultsProjectEntryNameKey];
		[projectNamesByServer addObject:projectName toArrayForKey:urlString];
	}
	
	NSMutableArray *servers = [NSMutableArray array];
	NSEnumerator *urlEnum = [projectNamesByServer keyEnumerator];
	NSString *urlString;
	while((urlString = [urlEnum nextObject]) != nil)
	{
		NSURL *url = [NSURL URLWithString:urlString];
		NSArray *projectNames = [projectNamesByServer objectForKey:urlString];
		CCMServer *server = [[[CCMServer alloc] initWithURL:url andProjectNames:projectNames] autorelease];
		[servers addObject:server];
	}
	return servers;
}

@end
