
#import "CCMAppController.h"
#import "CCMGrowlAdaptor.h"
#import "CCMBuildNotificationFactory.h"
#import "CCMBuildStatusTransformer.h"
#import "CCMRelativeDateTransformer.h"
#import "CCMTimeIntervalTransformer.h"
#import "CCMBuildTimer.h"
#import "CCMSoundPlayer.h"


@implementation CCMAppController

- (void)setupRequestCache
{
	NSURLCache *cache = [NSURLCache sharedURLCache];
	[cache setDiskCapacity:0];
	[cache setMemoryCapacity:5*1024*1024];
}

- (void)registerValueTransformers
{
	CCMBuildStatusTransformer *statusTransformer = [[[CCMBuildStatusTransformer alloc] init] autorelease];
	[statusTransformer setImageFactory:imageFactory];
	[NSValueTransformer setValueTransformer:statusTransformer forName:CCMBuildStatusTransformerName];
	
	CCMRelativeDateTransformer *relativeDateTransformer = [[[CCMRelativeDateTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:relativeDateTransformer forName:CCMRelativeDateTransformerName];

	CCMTimeIntervalTransformer *timeIntervalTransformer = [[[CCMTimeIntervalTransformer alloc] init] autorelease];
	[NSValueTransformer setValueTransformer:timeIntervalTransformer forName:CCMTimeIntervalTransformerName];
}

- (void)startServices
{
    CCMBuildTimer *buildTimer = [[CCMBuildTimer alloc] init];
    [buildTimer start];
    
    CCMSoundPlayer *soundPlayer = [[CCMSoundPlayer alloc] init];
    [soundPlayer start];

	[growlAdaptor start]; 

	[serverMonitor setNotificationCenter:[NSNotificationCenter defaultCenter]];
	[serverMonitor setNotificationFactory:[[[CCMBuildNotificationFactory alloc] init] autorelease]];
	[serverMonitor start];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
	@try
	{
		[self setupRequestCache];
		[self registerValueTransformers];
        [self startServices];
		if([[serverMonitor projects] count] == 0)
			[preferencesController showWindow:self];
	}
	@catch(NSException *e)
	{
		// ignore; if we don't the run-loop might not get set up properly
	}
}

@end
