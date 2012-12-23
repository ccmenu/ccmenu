/*

based on NSAppleScript+HandlerCalls.h by Buzz Andersen
More information at: http://www.scifihifi.com/weblog/mac/Cocoa-AppleEvent-Handlers.html

 */

#import <Foundation/Foundation.h>

@interface NSAppleScript(EDAdditions)

+ (NSAppleScript *)scriptWithName:(NSString *)name;

- (id)callHandler:(NSString *)handler;
- (id)callHandler:(NSString *)handler withArguments:(NSArray *)arguments;
- (id)callHandler:(NSString *)handler withArguments:(NSArray *)arguments errorInfo:(NSDictionary **) errorInfo;

@end
