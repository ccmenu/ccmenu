
#import "CCMKeychainHelper.h"

@implementation CCMKeychainHelper

+ (BOOL)setPassword:(NSString *)password forURLString:(NSString *)aString error:(NSError **)errorPtr
{
    return [self setPassword:password forURL:[NSURL URLWithString:aString] error:errorPtr];
}

+ (BOOL)setPassword:(NSString *)password forURL:(NSURL *)aURL error:(NSError **)errorPtr
{
    NSDictionary *query = @{
        (id)kSecClass: (id)kSecClassInternetPassword,
        (id)kSecAttrServer: [aURL host],
        (id)kSecAttrPort: [aURL port],
        (id)kSecAttrAccount: [aURL user]
    };
    NSDictionary *item = @{
        (id)kSecClass: (id)kSecClassInternetPassword,
        (id)kSecAttrServer: [aURL host],
        (id)kSecAttrPort: [aURL port],
        (id)kSecAttrAccount: [aURL user],
        (id)kSecAttrProtocol: [aURL scheme],
        (id)kSecValueData:[password dataUsingEncoding:NSUTF8StringEncoding]
    };

    OSStatus status = SecItemAdd((CFDictionaryRef)item, NULL);
    if(status == errSecDuplicateItem)
        status = SecItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)item);

    if(status != noErr)
    {
        if(errorPtr != NULL)
            *errorPtr = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        return NO;
    }
    return YES;
}


+ (NSString *)passwordForURLString:(NSString *)aString error:(NSError **)errorPtr
{
    return [self passwordForURL:[NSURL URLWithString:aString] error:errorPtr];
}

+ (NSString *)passwordForURL:(NSURL *)aURL error:(NSError **)errorPtr
{
    if([aURL user] == nil)
        return nil;

    NSDictionary *query = @{
        (id)kSecClass: (id)kSecClassInternetPassword,
        (id)kSecAttrServer: [aURL host],
        (id)kSecAttrPort: [aURL port],
        (id)kSecAttrAccount: [aURL user],
        (id)kSecReturnData: @YES
    };
    NSData *data = NULL;

    OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef*)&data);

    if(status != noErr)
    {
        if(errorPtr != NULL)
            *errorPtr = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        return nil;
    }
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}


+ (NSString *)accountForURLString:(NSString *)aString error:(NSError **)errorPtr
{
    return [self accountForURL:[NSURL URLWithString:aString] error:errorPtr];
}

+ (NSString *)accountForURL:(NSURL *)aURL error:(NSError **)errorPtr
{
    if([aURL host] == nil)
        return nil;

    NSDictionary *query = @{
        (id)kSecClass: (id)kSecClassInternetPassword,
        (id)kSecAttrServer: [aURL host],
        (id)kSecReturnAttributes: @YES
    };
    NSDictionary *attributes = nil;

    OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef*)&attributes);

    if(status != noErr)
    {
        if(errorPtr != NULL)
            *errorPtr = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        return nil;
    }
    return [attributes objectForKey:kSecAttrAccount];
}


@end
