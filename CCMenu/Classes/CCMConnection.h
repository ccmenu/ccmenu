
#import <Cocoa/Cocoa.h>


@interface CCMConnection : NSObject <NSURLConnectionDataDelegate>
{
	NSURLConnection     *urlConnection;
    NSHTTPURLResponse   *receivedResponse;
	NSMutableData	    *receivedData;
}

@property(nonatomic, readonly, copy) NSURL *serverURL;
@property(nonatomic, assign) id delegate;

- (id)initWithServerURL:(NSURL *)theServerUrl;
- (id)initWithURLString:(NSString *)theServerUrlAsString;

- (void)requestServerStatus;
- (void)cancelStatusRequest;

// subclasses only

- (void)setUpForNewRequest;
- (void)cleanUpAfterStatusRequest;

- (NSString *)errorStringForError:(NSError *)error;
- (NSString *)errorStringForResponse:(NSHTTPURLResponse *)response;
- (NSString *)errorStringForParseError:(NSError *)error;

@end


@protocol CCMConnectionDelegate

- (NSURLCredential *)connection:(CCMConnection *)connection credentialForAuthenticationChallange:(NSURLAuthenticationChallenge *)challenge;

- (void)connection:(CCMConnection *)connection didReceiveServerStatus:(NSArray *)projectInfoList;
- (void)connection:(CCMConnection *)connection hadTemporaryError:(NSString *)errorString;

@end
