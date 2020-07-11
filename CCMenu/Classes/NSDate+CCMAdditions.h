
#import <Cocoa/Cocoa.h>

@interface NSDate(CCMAdditions)

- (NSString *)descriptionRelativeToNow;

- (NSString *)descriptionOfIntervalWithDate:(NSDate *)other;
- (NSString *)descriptionOfIntervalSinceDate:(NSDate *)other withSign:(BOOL)withSign;

+ (NSString *)descriptionOfInterval:(NSTimeInterval)interval withSign:(BOOL)withSign;

- (NSString *)timeAsString;

@end
