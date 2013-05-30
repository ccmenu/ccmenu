
#import <Foundation/Foundation.h>


@interface CCMConnectionBase : NSObject
{
    NSURL	    *serverUrl;
    NSRunLoop   *runLoop;
	id          delegate;
}

@property(nonatomic, weak) NSRunLoop *runLoop;
@property(nonatomic, weak) id delegate;

- (id)initWithServerURL:(NSURL *)theServerUrl;
- (id)initWithURLString:(NSString *)theServerUrlAsString;

- (NSURL *)serverURL;

// for subclassers only

- (NSString *)errorStringForError:(NSError *)error;
- (NSString *)errorStringForResponse:(NSHTTPURLResponse *)response;
- (NSString *)errorStringForParseError:(NSError *)error;

@end
