
#import "CCMServer.h"
#import "CCMProject.h"


@implementation CCMServer

- (id)initWithProjectNames:(NSArray *)projectNames
{
	[super init];
	projects = [[NSMutableDictionary alloc] init];
	NSEnumerator *nameEnum = [projectNames objectEnumerator];
	NSString *name;
	while((name = [nameEnum nextObject]) != nil)
		[projects setObject:[[[CCMProject alloc] initWithName:name] autorelease] forKey:name];		
	return self;
}

- (void)updateWithProjectInfo:(NSDictionary *)info
{
	CCMProject *project = [projects objectForKey:[info objectForKey:@"name"]];
	if(project != nil)
		[project updateWithInfo:info];
}

- (CCMProject *)projectNamed:(NSString *)name
{
	return [projects objectForKey:name];
}

- (NSArray *)projects
{
	return [projects allValues];
}

@end
