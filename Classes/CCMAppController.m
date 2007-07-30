
#import "CCMAppController.h"
#import "CCMConnection.h"
#import "CCMProjectInfo.h"
#import "CCMServerMonitor.h"


@implementation CCMAppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
	NSURL *url = [NSURL URLWithString:@"http://cclive.thoughtworks.com/dashboard/cctray.xml"];
//	NSURL *url = [NSURL URLWithString:@"http://localhost:8080/dashboard/cctray.xml"];
	CCMConnection *connection = [[[CCMConnection alloc] initWithURL:url] autorelease];
	monitor = [[CCMServerMonitor alloc] initWithConnection:connection];
	[monitor start];
}

- (IBAction)checkStatus:(id)sender
{
	[monitor pollServer:self];
}

@end
