
#import <Cocoa/Cocoa.h>
#import "CCMProject.h"


@interface CCMServer : NSObject 
{
	NSURL				*url;
	NSMutableDictionary	*projects;
}

- (id)initWithURL:(NSURL *)url andProjectNames:(NSArray *)projectNames;

- (NSURL *)url;
- (NSArray *)projects;
- (CCMProject *)projectNamed:(NSString *)name;

- (void)updateWithProjectInfo:(NSDictionary *)info;

@end
