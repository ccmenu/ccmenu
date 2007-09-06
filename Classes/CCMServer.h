
#import <Cocoa/Cocoa.h>
#import "CCMProject.h"


@interface CCMServer : NSObject 
{
	NSMutableDictionary	*projects;
}

- (id)initWithProjectNames:(NSArray *)projectNames;

- (void)updateWithProjectInfo:(NSDictionary *)info;

- (CCMProject *)projectNamed:(NSString *)name;
- (NSArray *)projects;

@end
