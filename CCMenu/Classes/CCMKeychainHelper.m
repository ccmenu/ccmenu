
#import <Security/Security.h>
#import "CCMKeychainHelper.h"

@implementation CCMKeychainHelper

+ (NSString *)passwordForURLString:(NSString *)aString error:(NSError **)errorPtr
{
    return [self passwordForURL:[NSURL URLWithString:aString] error:errorPtr];
}

+ (NSString *)passwordForURL:(NSURL *)aURL error:(NSError **)errorPtr
{
    if([aURL user] == nil)
        return nil;

    const char *server = [[aURL host] UTF8String];
    const char *user = [[aURL user] UTF8String];
    UInt16 port = (UInt16) [[aURL port] integerValue];
    UInt32 pwLength;
    void *pwData;
    
    OSStatus status = SecKeychainFindInternetPassword(NULL, (UInt32)strlen(server), server, 0, NULL, (UInt32)strlen(user), user, 0, NULL, port, kSecProtocolTypeAny, kSecAuthenticationTypeAny, &pwLength, &pwData, NULL);
    
    if(status != noErr)
    {
        if(errorPtr != NULL)
            *errorPtr = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        return nil;
    }

    NSString *password = [[[NSString alloc] initWithBytes:pwData length:pwLength encoding:NSUTF8StringEncoding] autorelease];
    SecKeychainItemFreeContent(NULL, pwData);
    return password;
}

+ (BOOL)setPassword:(NSString *)password forURLString:(NSString *)aString error:(NSError **)errorPtr
{
    return [self setPassword:password forURL:[NSURL URLWithString:aString] error:errorPtr];
}

+ (BOOL)setPassword:(NSString *)password forURL:(NSURL *)aURL error:(NSError **)errorPtr
{
    const char *server = [[aURL host] UTF8String];
    const char *user = [[aURL user] UTF8String];
    const char *pwData = [password UTF8String];
    UInt16 port = (UInt16) [[aURL port] integerValue];
    SecKeychainItemRef itemRef = NULL;

    OSStatus status = SecKeychainFindInternetPassword(NULL, (UInt32)strlen(server), server, 0, NULL, (UInt32)strlen(user), user, 0, NULL, port, kSecProtocolTypeAny, kSecAuthenticationTypeAny, 0, NULL, &itemRef);

    if(status == errSecItemNotFound)
    {
        status = SecKeychainAddInternetPassword(NULL, (UInt32)strlen(server), server, 0, NULL, (UInt32)strlen(user), user, 0, NULL, port, kSecProtocolTypeAny, kSecAuthenticationTypeDefault, (UInt32)strlen(pwData), pwData, NULL);
    }
    else if(status == noErr)
    {
        status = SecKeychainItemModifyAttributesAndData(itemRef, NULL, (UInt32)strlen(pwData), pwData);
    }

    if(status != noErr)
    {
        if(errorPtr != NULL)
            *errorPtr = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        return NO;
    }
    return YES;
}

@end
