
#import "CCMAppController.h"
#import "CCMConnection.h"
#import "CCMServerMonitor.h"
#import "CCMGrowlAdaptor.h"
#import "CCMBuildStatusTransformer.h"
#import "CCMTimeSinceDateTransformer.h"


@implementation CCMAppController

- (void)registerFactoryDefaults
{
	NSDictionary *factorySettings = nil;
	
	NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"FactoryDefaults" ofType:@"plist"];
	NSAssert(resourcePath != nil, @"Missing resource; cannot find FactoryDefaults.");
	@try
	{
		factorySettings = [[NSString stringWithContentsOfFile:resourcePath] propertyList];
	}
	@catch(NSException *e)
	{
		// settings will remain nil which will be caught by assert below
	}
	NSAssert([factorySettings isKindOfClass:[NSDictionary class]], @"Damaged resource; FactoryDefaults is not a valid dictionary.");
	[[NSUserDefaults standardUserDefaults] registerDefaults:factorySettings];
}

- (void)start
{
	CCMBuildStatusTransformer *statusTransformer = [[[CCMBuildStatusTransformer alloc] init] autorelease];
	[statusTransformer setImageFactory:imageFactory];
	[NSValueTransformer setValueTransformer:statusTransformer forName:CCMBuildStatusTransformerName];
	
	CCMTimeSinceDateTransformer *dateTransformer = [[[CCMTimeSinceDateTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:dateTransformer forName:CCMTimeSinceDateTransformerName];
	
	CCMGrowlAdaptor *growlAdaptor = [[CCMGrowlAdaptor alloc] init]; // intentional 'leak'
	[growlAdaptor start]; 
	
	monitor = [[CCMServerMonitor alloc] init];
	[monitor setNotificationCenter:[NSNotificationCenter defaultCenter]];
	[monitor setUserDefaults:[NSUserDefaults standardUserDefaults]];
	[monitor start];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
	@try
	{
		[self registerFactoryDefaults];
		[self start];
	}
	@catch(NSException *e)
	{
		// ignore; if we don't the run-loop might not get set up properly
	}
}

@end
