
#import "CCMAppController.h"
#import "CCMBuildStatusTransformer.h"
#import "CCMRelativeDateTransformer.h"
#import "CCMTimeIntervalTransformer.h"
#import "CCMBuildTimer.h"
#import "CCMIsOneValueTransformer.h"
#import "CCMProjectDefaultValueTransformer.h"


@implementation CCMAppController

- (void)registerURLScheme
{
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleGetURLEvent:withReplyEvent:)
                                                     forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

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

    CCMIsOneValueTransformer *isOneTransformer = [[[CCMIsOneValueTransformer alloc] init] autorelease];
    [NSValueTransformer setValueTransformer:isOneTransformer forName:CCMIsOneTransformerName];

    CCMProjectDefaultValueTransformer *projectDefaultTransformer = [[[CCMProjectDefaultValueTransformer alloc] init] autorelease];
    [NSValueTransformer setValueTransformer:projectDefaultTransformer forName:CCMProjectDefaultValueTransformerName];
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

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    [self registerURLScheme];
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
            [userNotificationHandler openURLForNotification:userNotification];
    }
	@catch(NSException *e)
	{
		// ignore; if we don't the run-loop might not get set up properly
	}
}


- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
	NSString *url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
	url = [url stringByReplacingOccurrencesOfString:@"ccmenu+" withString:@"" options:NSAnchoredSearch range:NSMakeRange(0, [url length])];
	[preferencesController addProjectsForURL:url];
}


@end
