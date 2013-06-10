
#import <Cocoa/Cocoa.h>


@interface NSAlert(CCMAdditions)

+ (NSAlert *)alertWithText:(NSString *)messageText informativeText:(NSString *)informativeText;

@end