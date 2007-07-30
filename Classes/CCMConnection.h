
#import <Cocoa/Cocoa.h>


@interface CCMConnection : NSObject 
{
	NSURL *serverUrl;
}

- (id)initWithURL:(NSURL *)theServerUrl;

- (NSArray *)getProjectInfos;

@end
