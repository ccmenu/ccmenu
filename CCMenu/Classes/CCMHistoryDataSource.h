
#import <Cocoa/Cocoa.h>
#import "CCMUserDefaultsManager.h"

@interface CCMHistoryDataSource : NSObject
{
    NSArray *cachedURLs;
}

- (void)reloadData:(CCMUserDefaultsManager *)defaultsManager;

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox;
- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index1;
- (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)uncompletedString;

@end