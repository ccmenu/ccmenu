
#import <Foundation/Foundation.h>
#import "CCMConnectionBase.h"


@interface CCMTestConnection : CCMConnectionBase <NSURLConnectionDataDelegate>
{
    BOOL                didFinish;
    NSHTTPURLResponse   *receivedResponse;
    NSMutableData	    *receivedData;
    NSError             *receivedError;
}

- (NSArray *)retrieveServerStatus;
- (BOOL)testConnection;

@end


@protocol CCMTestConnectionDelegate <NSObject>

- (NSURLCredential *)connection:(CCMTestConnection *)connection willUseCredential:(NSURLCredential *)proposedCredential forMessage:(NSString *)message;

@end
