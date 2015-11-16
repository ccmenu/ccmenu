
#import <Cocoa/Cocoa.h>

enum {
    CCMProjectOrderNatural = 0,
    CCMProjectOrderAlphabetic = 1,
    CCMProjectOrderByBuildTime = 2
};


@interface CCMUserDefaultsManager : NSObject 
{
	NSUserDefaults	*userDefaults;
}

- (NSInteger)pollInterval;
- (BOOL)shouldShowAppIconWhenInPrefs;
- (BOOL)shouldShowTimerInMenu;
- (BOOL)shouldShowLastBuildTimes;
- (BOOL)shouldShowLastBuildLabel;
- (BOOL)shouldUseColorInMenuBar;
- (NSUInteger)projectOrder;

- (BOOL)shouldSendUserNotificationForBuildResult:(NSString *)result;
- (NSString *)soundForBuildResult:(NSString *)result;

- (void)addProject:(NSString *)projectName onServerWithURL:(NSString *)serverUrl;
- (BOOL)projectListContainsProject:(NSString *)projectName onServerWithURL:(NSString *)serverUrl;
- (NSArray *)projectList;

- (void)addServerURLToHistory:(NSString *)serverUrl;
- (NSArray *)serverURLHistory;

- (void)convertDefaultsIfNecessary;

@end


extern NSString *CCMDefaultsPollIntervalKey;

extern NSString *CCMDefaultsProjectListKey;
extern NSString *CCMDefaultsProjectEntryNameKey;
extern NSString *CCMDefaultsProjectEntryServerUrlKey;

extern NSString *CCMDefaultsServerUrlHistoryKey;
