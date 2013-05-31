
#import "CCMHistoryDataSource.h"
#import "CCMUserDefaultsManager.h"
#import "NSString+EDExtensions.h"


@implementation CCMHistoryDataSource

- (void)dealloc
{
    [cachedURLs release];
    [super dealloc];
}

- (void)reloadData:(CCMUserDefaultsManager *)defaultsManager
{
    [cachedURLs release];
    cachedURLs = [[[defaultsManager serverURLHistory] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] retain];
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return [cachedURLs count];
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    return [cachedURLs objectAtIndex:index];
}

- (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)uncompletedString
{
    for (NSString *urlString in cachedURLs)
    {
        if([urlString hasPrefixCaseInsensitive:uncompletedString])
            return urlString;
    }
    for (NSString *urlString in cachedURLs)
    {
        NSString *hostname = [[NSURL URLWithString:urlString] host];
        if([hostname hasPrefixCaseInsensitive:uncompletedString])
            return [urlString substringFromIndex:[urlString rangeOfString:hostname].location];
    }
    return @"";
}

@end