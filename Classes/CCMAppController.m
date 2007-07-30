
#import "CCMAppController.h"
#import "CCMConnection.h"
#import "CCMProjectInfo.h"
#import "CCMServerMonitor.h"
#import "CCMBuildStatusTransformer.h"


@implementation CCMAppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
	CCMBuildStatusTransformer *transformer = [[[CCMBuildStatusTransformer alloc] init] autorelease];
	[transformer setImageFactory:imageFactory];
	[NSValueTransformer setValueTransformer:transformer forName:CCMBuildStatusTransformerName];
	
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
