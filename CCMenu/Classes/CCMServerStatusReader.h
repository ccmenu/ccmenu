
#import <Cocoa/Cocoa.h>


@interface CCMServerStatusReader : NSObject 
{
	NSData *responseData;
}

- (id)initWithServerResponse:(NSData *)data;

- (NSArray *)readProjectInfos:(NSError **)errorPtr;

@end
