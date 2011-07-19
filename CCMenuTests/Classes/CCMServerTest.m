
#import "CCMServerTest.h"
#import "CCMProject.h"


@implementation CCMServerTest

- (void)testCreatesProjects
{	
	NSArray *projectNames = [NSArray arrayWithObject:@"connectfour"];
	server = [[[CCMServer alloc] initWithURL:nil andProjectNames:projectNames] autorelease];	

	NSArray *projectList = [server projects];
	
	STAssertEquals(1u, [projectList count], @"Should have created one project.");
	CCMProject *project = [projectList objectAtIndex:0];
	STAssertEqualObjects(@"connectfour", [project name], @"Should have set up project with right name."); 
}

@end
