
#import "NSCalendarDate+CCMAdditions.h"


@implementation NSCalendarDate(CCMAdditions)

- (NSString *)descriptionOfIntervalSinceDate:(NSCalendarDate *)other
{
	int days, hours, mins;
	[self years:NULL months:NULL days:&days hours:&hours minutes:&mins seconds:NULL sinceDate:other];
	
	if(days > 1)
		return [NSString stringWithFormat:@"%d days ago", days];
	if(days == 1)
		return @"1 day ago";
	if(hours > 1)
		return [NSString stringWithFormat:@"%d hours ago", hours];
	if(hours == 1)
		return @"an hour ago";
	if(mins > 1)
		return [NSString stringWithFormat:@"%d minutes ago", mins];
	if(mins == 1)
		return @"a minute ago";
	return @"less than a minute ago";
}

@end
