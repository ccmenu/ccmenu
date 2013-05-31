
#import <Cocoa/Cocoa.h>
#import "CCMConnectionBase.h"


@interface CCMConnection : CCMConnectionBase <NSURLConnectionDataDelegate>
{	
	NSURLConnection *urlConnection;
	NSMutableData	*receivedData;
}

- (void)requestServerStatus;
- (void)cancelStatusRequest;

@end


@protocol CCMConnectionDelegate

- (void)connection:(CCMConnection *)connection didReceiveServerStatus:(NSArray *)projectInfoList;
- (void)connection:(CCMConnection *)connection hadTemporaryError:(NSString *)errorString;

@end
