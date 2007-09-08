
#import <Cocoa/Cocoa.h>


@interface CCMUserDefaultsManager : NSObject 
{
	NSUserDefaults	*userDefaults;
}

- (int)pollInterval;

- (void)updateWithProjectInfos:(NSArray *)projectInfos withServerURL:(NSURL *)serverUrl;
- (NSArray *)projectListEntries;
- (NSArray *)servers;

@end


extern NSString *CCMDefaultsPollIntervalKey;

extern NSString *CCMDefaultsProjectListKey;
extern NSString *CCMDefaultsProjectEntryNameKey;
extern NSString *CCMDefaultsProjectEntryServerUrlKey;
