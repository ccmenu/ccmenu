
#import "CCMAppController.h"
#import "CCMConnection.h"
#import "CCMServerMonitor.h"
#import "CCMGrowlAdaptor.h"
#import "CCMBuildStatusTransformer.h"
#import "CCMTimeSinceDateTransformer.h"


@implementation CCMAppController

- (void)start
{
	CCMBuildStatusTransformer *statusTransformer = [[[CCMBuildStatusTransformer alloc] init] autorelease];
	[statusTransformer setImageFactory:imageFactory];
	[NSValueTransformer setValueTransformer:statusTransformer forName:CCMBuildStatusTransformerName];
	
	CCMTimeSinceDateTransformer *dateTransformer = [[[CCMTimeSinceDateTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:dateTransformer forName:CCMTimeSinceDateTransformerName];
	
	CCMGrowlAdaptor *growlAdaptor = [[CCMGrowlAdaptor alloc] init]; // intentional 'leak'
	[growlAdaptor start]; 
	
//	NSURL *url = [NSURL URLWithString:@"http://cclive.thoughtworks.com/dashboard/cctray.xml"];
	NSURL *url = [NSURL URLWithString:@"http://localhost:8080/dashboard/cctray.xml"];
	CCMConnection *connection = [[[CCMConnection alloc] initWithURL:url] autorelease];
	monitor = [[CCMServerMonitor alloc] initWithConnection:connection andProjects:[NSArray arrayWithObject:@"connectfour"]];
	[monitor setNotificationCenter:[NSNotificationCenter defaultCenter]];
	[monitor start];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
	@try
	{
		[self start];
	}
	@catch(NSException *e)
	{
		// ignore; if we don't the run-loop might not get set up properly
	}
}

@end
