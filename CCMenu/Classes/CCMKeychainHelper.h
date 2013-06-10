
#import <Cocoa/Cocoa.h>

@interface CCMKeychainHelper : NSObject

+ (NSString *)passwordForURLString:(NSString *)aString error:(NSError **)errorPtr;
+ (NSString *)passwordForURL:(NSURL *)aURL error:(NSError **)errorPtr;

+ (BOOL)setPassword:(NSString *)password forURLString:(NSString *)aString error:(NSError **)errorPtr;
+ (BOOL)setPassword:(NSString *)password forURL:(NSURL *)aURL error:(NSError **)errorPtr;

@end
