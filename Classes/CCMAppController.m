
#import "CCMAppController.h"
#import "CCMGrowlAdaptor.h"
#import "CCMBuildNotificationFactory.h"
#import "CCMBuildStatusTransformer.h"
#import "CCMTimeSinceDateTransformer.h"


@implementation CCMAppController

- (void)setupRequestCache
{
	NSURLCache *cache = [NSURLCache sharedURLCache];
	[cache setDiskCapacity:0];
	[cache setMemoryCapacity:2*1024*1024];
}

- (void)registerValueTransformers
{
	CCMBuildStatusTransformer *statusTransformer = [[[CCMBuildStatusTransformer alloc] init] autorelease];
	[statusTransformer setImageFactory:imageFactory];
	[NSValueTransformer setValueTransformer:statusTransformer forName:CCMBuildStatusTransformerName];
	
	CCMTimeSinceDateTransformer *dateTransformer = [[[CCMTimeSinceDateTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:dateTransformer forName:CCMTimeSinceDateTransformerName];
}

- (void)startGrowlAdaptor
{
	CCMGrowlAdaptor *growlAdaptor = [[CCMGrowlAdaptor alloc] init]; // intentional 'leak'
	[growlAdaptor start]; 
}

- (void)startServerMonitor
{
	monitor = [[CCMServerMonitor alloc] init];
	[monitor setNotificationCenter:[NSNotificationCenter defaultCenter]];
	[monitor setUserDefaults:[NSUserDefaults standardUserDefaults]];
	[monitor setNotificationFactory:[[[CCMBuildNotificationFactory alloc] init] autorelease]];
	[monitor start];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
	@try
	{
		[self setupRequestCache];
		[self registerValueTransformers];
		[self startGrowlAdaptor];
		[self startServerMonitor];
	}
	@catch(NSException *e)
	{
		// ignore; if we don't the run-loop might not get set up properly
	}
}

@end
