
#import "NSCalendarDate+CCMAdditionsTest.h"
#import "NSCalendarDate+CCMAdditions.h"


@implementation NSCalendarDate_CCMAdditionsTest

- (void)setUp
{
	reference = [NSCalendarDate dateWithYear:2007 month:7 day:14 hour:12 minute:0 second:0 timeZone:[NSTimeZone defaultTimeZone]];
}

- (void)testDescribesTimeSinceLastBuildWhenAMinuteOrLess
{
	NSCalendarDate *date = [reference dateByAddingYears:0 months:0 days:0 hours:0 minutes:0 seconds:-59];
	STAssertEqualObjects([reference relativeDescriptionOfPastDate:date], @"less than a minute ago", @"Should have returned time in minutes.");
}

- (void)testDescribesTimeSinceLastBuildAsOneMinute
{
	NSCalendarDate *date = [reference dateByAddingYears:0 months:0 days:0 hours:0 minutes:-1 seconds:0];
	STAssertEqualObjects([reference relativeDescriptionOfPastDate:date], @"a minute ago", @"Should have returned time in minutes.");
}

- (void)testDescribesTimeSinceLastBuildInMinutes
{
	NSCalendarDate *date = [reference dateByAddingYears:0 months:0 days:0 hours:0 minutes:-2 seconds:0];
	STAssertEqualObjects([reference relativeDescriptionOfPastDate:date], @"2 minutes ago", @"Should have returned time in minutes.");
}

- (void)testDescribesTimeSinceLastBuildAsOneHour
{
	NSCalendarDate *date = [reference dateByAddingYears:0 months:0 days:0 hours:-1 minutes:0 seconds:0];
	STAssertEqualObjects([reference relativeDescriptionOfPastDate:date], @"an hour ago", @"Should have returned time in hours.");
}

- (void)testDescribesTimeSinceLastBuildInHours
{
	NSCalendarDate *date = [reference dateByAddingYears:0 months:0 days:0 hours:-2 minutes:0 seconds:0];
	STAssertEqualObjects([reference relativeDescriptionOfPastDate:date], @"2 hours ago", @"Should have returned time in hours.");
}

- (void)testDescribesTimeSinceLastBuildAsOneDay
{
	NSCalendarDate *date = [reference dateByAddingYears:0 months:0 days:-1 hours:0 minutes:0 seconds:0];
	STAssertEqualObjects([reference relativeDescriptionOfPastDate:date], @"1 day ago", @"Should have returned time in days.");
}

- (void)testDescribesTimeSinceLastBuildInDays
{
	NSCalendarDate *date = [reference dateByAddingYears:0 months:0 days:-2 hours:-2 minutes:0 seconds:0];
	STAssertEqualObjects([reference relativeDescriptionOfPastDate:date], @"2 days ago", @"Should have returned time in days.");
}


- (void)testDescribesLessThan60sIntervalInSeconds
{
	NSCalendarDate *date = [reference dateByAddingYears:0 months:0 days:0 hours:0 minutes:0 seconds:59];
	STAssertEqualObjects([date descriptionOfIntervalWithDate:reference], @"59s", @"Should have returned time in seconds.");
}

- (void)testDescribesLessThan60minuteIntervalInMinutesAndSeconds
{
	NSCalendarDate *date = [reference dateByAddingYears:0 months:0 days:0 hours:0 minutes:59 seconds:9];
	STAssertEqualObjects([date descriptionOfIntervalWithDate:reference], @"59:09", @"Should have returned time in minutes and seconds.");
}

- (void)testDescribesMoreThan60minuteIntervalInHoursMinutesAndSeconds
{
	NSCalendarDate *date = [reference dateByAddingYears:0 months:0 days:1 hours:0 minutes:8 seconds:9];
	STAssertEqualObjects([date descriptionOfIntervalWithDate:reference], @"24:08:09", @"Should have returned time in hours, minutes, seconds.");
}


- (void)testDescribesLessThan60sIntervalInSecondsWithPlusSign
{
	NSCalendarDate *date = [reference dateByAddingYears:0 months:0 days:0 hours:0 minutes:0 seconds:59];
	STAssertEqualObjects([date descriptionOfIntervalSinceDate:reference withSign:YES], @"+59s", @"Should have returned time with plus sign.");
}

- (void)testDescribesLessThan60sReverseIntervalSecondsWithMinusSign
{
	NSCalendarDate *date = [reference dateByAddingYears:0 months:0 days:0 hours:0 minutes:0 seconds:-59];
	STAssertEqualObjects([date descriptionOfIntervalSinceDate:reference withSign:YES], @"-59s", @"Should have returned time with minus sign.");
}

- (void)testDescribesReverseLessThan60minuteIntervalInMinutesAndSecondsWithMinusSign
{
	NSCalendarDate *date = [reference dateByAddingYears:0 months:0 days:0 hours:0 minutes:-59 seconds:-9];
	STAssertEqualObjects([date descriptionOfIntervalSinceDate:reference withSign:YES ], @"-59:09", @"Should have returned time with one minus sign in front.");
}

@end
