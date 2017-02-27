
#import "CCMUserDefaultsManager.h"
#import "CCMProject.h"
#import "NSArray+CCMAdditions.h"
#import "CCMBuildNotificationFactory.h"

NSString *CCMDefaultsProjectListKey = @"Projects";
NSString *CCMDefaultsProjectEntryNameKey = @"projectName";
NSString *CCMDefaultsProjectEntryServerUrlKey = @"serverUrl";
NSString *CCMDefaultsProjectEntryDisplayNameKey = @"displayName";
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

- (BOOL)shouldShowAppIconWhenInPrefs
{
    return [userDefaults boolForKey:@"ShowAppIconWhenInPrefs"];
}

- (BOOL)shouldShowTimerInMenu
{
    return [userDefaults boolForKey:@"ShowTimerInMenu"];
}

- (BOOL)shouldShowLastBuildTimes
{
    return [userDefaults boolForKey:@"ShowLastBuildTimes"];
}

- (BOOL)shouldShowLastBuildLabel
{
    return [userDefaults boolForKey:@"ShowLastBuildLabel"];
}

- (BOOL)shouldUseColorInMenuBar
{
    return [userDefaults boolForKey:@"UseColorInMenuBar"];
}

- (void)setShouldUseSymbolsForAllStatesInMenuBar:(BOOL)flag
{
    [userDefaults setBool:flag forKey:@"UseSymbolsForAllStatesInMenuBar"];
}

- (BOOL)shouldUseSymbolsForAllStatesInMenuBar
{
    return [userDefaults boolForKey:@"UseSymbolsForAllStatesInMenuBar"];
}

- (BOOL)shouldHideSuccessfulBuilds
{
    return [userDefaults boolForKey:@"HideSuccessfulBuilds"];
}

- (NSUInteger)projectOrder
{
    return (NSUInteger)[userDefaults integerForKey:@"ProjectOrder"];
}

- (BOOL)shouldSendUserNotificationForEvent:(NSString *)event
{
    NSString *sendNotificationKey = [NSString stringWithFormat:@"SendNotification %@", event];
    return [userDefaults boolForKey:sendNotificationKey];
}

- (NSString *)soundForEvent:(NSString *)event
{
    NSString *playSoundKey = [NSString stringWithFormat:@"PlaySound %@", event];
    if([userDefaults boolForKey:playSoundKey])
    {
        NSString *soundKey = [NSString stringWithFormat:@"Sound %@", event]; // slightly naughty
        return [userDefaults stringForKey:soundKey];
    }
    return nil;
}

- (void)addProject:(CCMProject *)project
{
    if([self projectListContainsProject:[project name] onServerWithURL:[[project serverURL] absoluteString]])
        return;
    NSMutableArray *mutableList = [NSMutableArray arrayWithArray:[userDefaults arrayForKey:CCMDefaultsProjectListKey]];
    NSMutableDictionary *entry = [NSMutableDictionary dictionary];
    [entry setObject:[project name] forKey:CCMDefaultsProjectEntryNameKey];
    [entry setObject:[[project serverURL] absoluteString] forKey:CCMDefaultsProjectEntryServerUrlKey];
    if([project displayName] != nil)
        [entry setObject:[project displayName] forKey:CCMDefaultsProjectEntryDisplayNameKey];
    [mutableList addObject:entry];
    [userDefaults setObject:mutableList forKey:CCMDefaultsProjectListKey];

}

- (BOOL)projectListContainsProject:(NSString *)projectName onServerWithURL:(NSString *)serverUrl
{
    for(NSDictionary *entry in [userDefaults arrayForKey:CCMDefaultsProjectListKey])
    {
        if([[entry objectForKey:CCMDefaultsProjectEntryNameKey] isEqualToString:projectName]
           && [[entry objectForKey:CCMDefaultsProjectEntryServerUrlKey] isEqualToString:serverUrl])
            return YES;
    }
    return NO;
}

- (NSArray *)projectList
{
    NSArray *defaultsEntryList = [userDefaults arrayForKey:CCMDefaultsProjectListKey];
    if(defaultsEntryList == nil)
        return [NSArray array];

    NSMutableArray *projectList = [NSMutableArray arrayWithCapacity:[defaultsEntryList count]];
    for(NSDictionary *entry in defaultsEntryList)
    {
        CCMProject *p = [[[CCMProject alloc] initWithName:[entry valueForKey:CCMDefaultsProjectEntryNameKey]] autorelease];
        [p setServerURL:[entry valueForKey:CCMDefaultsProjectEntryServerUrlKey]];
        [p setDisplayName:[entry valueForKey:CCMDefaultsProjectEntryDisplayNameKey]];
        [projectList addObject:p];
    }
    return projectList;
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

    for(NSString *result in @[ CCMSuccessfulBuild, CCMBrokenBuild, CCMStillFailingBuild, CCMFixedBuild ])
    {
        [self addPlaySoundKeys:result];
        [self addSendNotificationKeys:result];
    }
}

- (void)addPlaySoundKeys:(NSString *)buildResult
{
    NSString *playSoundKey = [NSString stringWithFormat:@"PlaySound %@", buildResult];
    if([userDefaults objectForKey:playSoundKey] == nil)
    {
        NSString *soundKey = [NSString stringWithFormat:@"Sound %@", buildResult];
        NSString *sound = [userDefaults stringForKey:soundKey];
        if((sound == nil) || [sound isEqualToString:@"-"])
        {
            [userDefaults setBool:NO forKey:playSoundKey];
            [userDefaults setObject:@"Sosumi" forKey:soundKey];
        }
        else
        {
            [userDefaults setBool:YES forKey:playSoundKey];
        }
    }
}

- (void)addSendNotificationKeys:(NSString *)buildResult
{
    NSString *sendNotificationKey = [NSString stringWithFormat:@"SendNotification %@", buildResult];
    if([userDefaults objectForKey:sendNotificationKey] == nil)
    {
        [userDefaults setBool:YES forKey:sendNotificationKey];
    }
}


@end
