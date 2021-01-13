
#import <XCTest/XCTest.h>
#import "NSDate+CCMAdditions.h"


@interface NSDate_CCMAdditionsTest : XCTestCase
{
	NSDate              *now;
    NSCalendar          *calendar;
    NSDateComponents    *comps;
}

@end


@implementation NSDate_CCMAdditionsTest

- (void)setUp
{
	now = [NSDate date];
    calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    comps = [[[NSDateComponents alloc] init] autorelease];
}

- (void)testDescribesTimeSinceLastBuildWhenAMinuteOrLess
{
    [comps setSecond:-59];
    NSDate *date = [calendar dateByAddingComponents:comps toDate:now options:0];
	XCTAssertEqualObjects([date descriptionRelativeToNow], @"less than a minute ago", @"Should have returned time in minutes.");
}

- (void)testDescribesTimeSinceLastBuildAsOneMinute
{
    [comps setMinute:-1];
    NSDate *date = [calendar dateByAddingComponents:comps toDate:now options:0];
	XCTAssertEqualObjects([date descriptionRelativeToNow], @"a minute ago", @"Should have returned time in minutes.");
}

- (void)testDescribesTimeSinceLastBuildInMinutes
{
    [comps setMinute:-2];
    NSDate *date = [calendar dateByAddingComponents:comps toDate:now options:0];
	XCTAssertEqualObjects([date descriptionRelativeToNow], @"2 minutes ago", @"Should have returned time in minutes.");
}

- (void)testDescribesTimeSinceLastBuildAsOneHour
{
    [comps setHour:-1];
    NSDate *date = [calendar dateByAddingComponents:comps toDate:now options:0];
	XCTAssertEqualObjects([date descriptionRelativeToNow], @"an hour ago", @"Should have returned time in hours.");
}

- (void)testDescribesTimeSinceLastBuildInHours
{
    [comps setHour:-2];
    NSDate *date = [calendar dateByAddingComponents:comps toDate:now options:0];
	XCTAssertEqualObjects([date descriptionRelativeToNow], @"2 hours ago", @"Should have returned time in hours.");
}

- (void)testDescribesTimeSinceLastBuildAsYesterday
{
    [comps setHour:-24];
    [comps setSecond:-1]; // if this runs exactly at midnight...
    NSDate *date = [calendar dateByAddingComponents:comps toDate:now options:0];
	XCTAssertEqualObjects([date descriptionRelativeToNow], @"yesterday", @"Should have returned yesterday.");
}

- (void)testDescribesTimeSinceLastBuildInDays
{
    [comps setHour:-48];
    NSDate *date = [calendar dateByAddingComponents:comps toDate:now options:0];
	XCTAssertEqualObjects([date descriptionRelativeToNow], @"2 days ago", @"Should have returned time in days.");
}


- (void)testDescribesLessThan60sIntervalInSeconds
{
    [comps setSecond:59];
    NSDate *date = [calendar dateByAddingComponents:comps toDate:now options:0];
	XCTAssertEqualObjects([date descriptionOfIntervalWithDate:now], @"59s", @"Should have returned time in seconds.");
}

- (void)testDescribesLessThan60minuteIntervalInMinutesAndSeconds
{
    [comps setMinute:59];
    [comps setSecond:9];
    NSDate *date = [calendar dateByAddingComponents:comps toDate:now options:0];
	XCTAssertEqualObjects([date descriptionOfIntervalWithDate:now], @"59:09", @"Should have returned time in minutes and seconds.");
}

- (void)testDescribesMoreThan60minuteIntervalInHoursMinutesAndSeconds
{
    [comps setDay:1];
    [comps setMinute:8];
    [comps setSecond:9];
    NSDate *date = [calendar dateByAddingComponents:comps toDate:now options:0];
	XCTAssertEqualObjects([date descriptionOfIntervalWithDate:now], @"24:08:09", @"Should have returned time in hours, minutes, seconds.");
}


- (void)testDescribesLessThan60sIntervalInSecondsWithPlusSign
{
    [comps setSecond:59];
    NSDate *date = [calendar dateByAddingComponents:comps toDate:now options:0];
	XCTAssertEqualObjects([date descriptionOfIntervalSinceDate:now withSign:YES], @"+59s", @"Should have returned time with plus sign.");
}

- (void)testDescribesLessThan60sReverseIntervalSecondsWithMinusSign
{
    [comps setSecond:-59];
    NSDate *date = [calendar dateByAddingComponents:comps toDate:now options:0];
	XCTAssertEqualObjects([date descriptionOfIntervalSinceDate:now withSign:YES], @"-59s", @"Should have returned time with minus sign.");
}

- (void)testDescribesReverseLessThan60minuteIntervalInMinutesAndSecondsWithMinusSign
{
    [comps setMinute:-59];
    [comps setSecond:-9];
    NSDate *date = [calendar dateByAddingComponents:comps toDate:now options:0];
	XCTAssertEqualObjects([date descriptionOfIntervalSinceDate:now withSign:YES], @"-59:09", @"Should have returned time with one minus sign in front.");
}

- (void)testDescribesCloseToZeroLengthIntervalWithSign
{
    [comps setNanosecond:-100];
    NSDate *date = [calendar dateByAddingComponents:comps toDate:now options:0];
    XCTAssertEqualObjects([date descriptionOfIntervalSinceDate:now withSign:YES], @"-00s", @"Should have returned zero seconds with correct sign.");
}

- (void)testDescribesZeroLengthIntervalWithEmptyString
{
	XCTAssertEqualObjects([now descriptionOfIntervalSinceDate:now withSign:NO], @"", @"Should have returned empty string.");
}

@end
