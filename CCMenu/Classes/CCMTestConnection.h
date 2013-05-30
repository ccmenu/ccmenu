
#import <Foundation/Foundation.h>
#import "CCMConnectionBase.h"


@interface CCMTestConnection : CCMConnectionBase
{
    NSInteger   statusCode;
    BOOL        didFinish;
    NSError     *error;
}

- (BOOL)testConnection;

// NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

@end


@interface NSObject(CCMTestConnectionDelegate)

- (NSURLCredential *)connection:(CCMTestConnection *)connection willUseCredential:(NSURLCredential *)proposedCredential forMessage:(NSString *)message;

@end
