
#import <Cocoa/Cocoa.h>


@interface CCMConnection : NSObject 
{
	NSURL			*serverUrl;
	
	NSURLConnection *urlConnection;
	NSMutableData	*receivedData;
	
	id delegate;
}

- (id)initWithServerURL:(NSURL *)theServerUrl;
- (id)initWithURLString:(NSString *)theServerUrlAsString;

- (NSURL *)serverURL;

- (void)setDelegate:(id)aDelegate;
- (id)delegate;

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
