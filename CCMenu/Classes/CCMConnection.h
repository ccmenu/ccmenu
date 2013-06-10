
#import <Cocoa/Cocoa.h>


@interface CCMConnection : NSObject <NSURLConnectionDataDelegate>
{
	NSURLConnection     *nsurlConnection;
    NSHTTPURLResponse   *receivedResponse;
	NSMutableData	    *receivedData;
}

@property(nonatomic, readonly, copy) NSURL *feedURL;
@property(nonatomic, retain) NSURLCredential *credential;
@property(nonatomic, assign) id delegate;

- (id)initWithFeedURL:(NSURL *)theFeedURL;
- (id)initWithURLString:(NSString *)theFeedURL;

- (void)requestServerStatus;
- (void)cancelRequest;

// subclasses only

- (void)setUpForNewRequest;
- (void)cleanUpAfterRequest;

- (NSString *)errorStringForError:(NSError *)error;
- (NSString *)errorStringForResponse:(NSHTTPURLResponse *)response;
- (NSString *)errorStringForParseError:(NSError *)error;

@end


@protocol CCMConnectionDelegate

- (void)connection:(CCMConnection *)connection didReceiveServerStatus:(NSArray *)projectInfoList;
- (void)connection:(CCMConnection *)connection hadTemporaryError:(NSString *)errorString;

@end
