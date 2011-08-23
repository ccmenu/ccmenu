
#import <Cocoa/Cocoa.h>


@interface NSCalendarDate(CCMAdditions)

- (NSString *)relativeDescriptionOfPastDate:(NSCalendarDate *)other;
- (NSString *)descriptionOfIntervalWithDate:(NSCalendarDate *)other;
- (NSString *)descriptionOfIntervalSinceDate:(NSCalendarDate *)other withSign:(BOOL)withSign;

+ (NSString *)descriptionOfInterval:(NSTimeInterval)interval withSign:(BOOL)withSign;

@end


@interface NSDate(CCMAdditions)

- (NSString *)timeAsString;

@end