
#import <Cocoa/Cocoa.h>
#import "CCMConnectionBase.h"


@interface CCMConnection : CCMConnectionBase
{	
	NSURLConnection *urlConnection;
	NSMutableData	*receivedData;
}

- (BOOL)testConnection;
- (NSArray *)retrieveServerStatus;

- (void)requestServerStatus;
- (void)cancelStatusRequest;


// internal, don't use

- (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error;
- (NSURLConnection *)newAsynchronousRequest:(NSURLRequest *)request;

@end


@interface NSObject(CCMConnectionDelegate)

- (void)connection:(CCMConnection *)connection didReceiveServerStatus:(NSArray *)projectInfoList;
- (void)connection:(CCMConnection *)connection hadTemporaryError:(NSString *)errorString;

@end
