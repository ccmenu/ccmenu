
#import "CCMAppController.h"
#import "CCMUserNotificationHandler.h"
#import "CCMBuildNotificationFactory.h"
#import "CCMBuildStatusTransformer.h"
#import "CCMRelativeDateTransformer.h"
#import "CCMTimeIntervalTransformer.h"
#import "CCMBuildTimer.h"


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
    
	[serverMonitor setNotificationCenter:[NSNotificationCenter defaultCenter]];
	[serverMonitor setNotificationFactory:[[[CCMBuildNotificationFactory alloc] init] autorelease]];
	[serverMonitor start];

    [userNotificationHandler start];
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
      
        NSUserNotification *userNotification = [[aNotification userInfo] objectForKey:@"NSApplicationLaunchUserNotificationKey"];
        if(userNotification != nil)
            [userNotificationHandler userNotificationCenter:nil didActivateNotification:userNotification];
	}
	@catch(NSException *e)
	{
		// ignore; if we don't the run-loop might not get set up properly
	}
}

@end
