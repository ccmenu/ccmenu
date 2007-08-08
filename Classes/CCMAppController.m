
#import "CCMAppController.h"
#import "CCMConnection.h"
#import "CCMServerMonitor.h"
#import "CCMBuildStatusTransformer.h"
#import "CCMTimeSinceDateTransformer.h"


@implementation CCMAppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
	CCMBuildStatusTransformer *statusTransformer = [[[CCMBuildStatusTransformer alloc] init] autorelease];
	[statusTransformer setImageFactory:imageFactory];
	[NSValueTransformer setValueTransformer:statusTransformer forName:CCMBuildStatusTransformerName];
	
	CCMTimeSinceDateTransformer *dateTransformer = [[[CCMTimeSinceDateTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:dateTransformer forName:CCMTimeSinceDateTransformerName];
	
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
