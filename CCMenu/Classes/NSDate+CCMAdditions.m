
#import "NSString+EDExtensions.h"
#import "NSDate+CCMAdditions.h"

@implementation NSDate(CCMAdditions)

- (NSString *)descriptionRelativeToNow
{
    NSCalendar *calender = [NSCalendar autoupdatingCurrentCalendar];
    NSDate *now = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSinceDate:self];

    if(interval < 60)
        return @"less than a minute ago";
    if(interval < 120)
        return @"a minute ago";
    if(interval < 3600)
        return [NSString stringWithFormat:@"%ld minutes ago", (long)(interval / 60)];
    if(interval < 2 * 3600)
        return @"an hour ago";
    if(interval < 24 * 3600)
        return [NSString stringWithFormat:@"%ld hours ago", (long)(interval / 3600)];
    if([calender isDateInYesterday:self])
        return @"yesterday";
    return [NSString stringWithFormat:@"%ld days ago", MAX(2, (long)(interval / (24 * 3600)))];
}

- (NSString *)descriptionOfIntervalWithDate:(NSDate *)other
{
    return [self descriptionOfIntervalSinceDate:other withSign:NO];
}

- (NSString *)descriptionOfIntervalSinceDate:(NSDate *)other withSign:(BOOL)withSign
{
    return [[self class] descriptionOfInterval:[self timeIntervalSinceDate:other] withSign:withSign];
}

+ (NSString *)descriptionOfInterval:(NSTimeInterval)timeInterval withSign:(BOOL)withSign
{
    int interval = (int)timeInterval;
    NSString *sign = withSign ? ((interval < 0) ? @"-" : @"+") : @"";
    interval = abs(interval);

    if(interval > 3600)
        return [NSString stringWithFormat:@"%@%d:%02d:%02d", sign, interval / 3600, (interval / 60) % 60, interval % 60];
    if(interval > 60)
        return [NSString stringWithFormat:@"%@%d:%02d", sign, interval / 60, interval % 60];
    if(interval > 0)
        return [NSString stringWithFormat:@"%@%ds", sign, interval];
    return @"";
}

@end
