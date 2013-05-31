
#import <Foundation/Foundation.h>
#import "CCMConnection.h"


@interface CCMSyncConnection : CCMConnection
{
    BOOL                didFinish;
    NSError             *receivedError;
}

@property(nonatomic, assign) NSRunLoop *runLoop;

- (NSArray *)retrieveServerStatus;
- (BOOL)testConnection;

@end
