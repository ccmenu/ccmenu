
#import <Cocoa/Cocoa.h>


@interface CCMServerStatusReader : NSObject 
{
	NSData *responseData;
}

- (id)initWithServerResponse:(NSData *)data;

- (NSError *)tryParse;

- (NSArray *)projectInfos;

@end
