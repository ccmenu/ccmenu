
#import "CCMAppController.h"
#import "CCMBuildStatusTransformer.h"
#import "CCMRelativeDateTransformer.h"
#import "CCMTimeIntervalTransformer.h"
#import "CCMBuildTimer.h"
#import "CCMIsOneValueTransformer.h"
#import "CCMProjectDefaultValueTransformer.h"


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

- (void)showAppStoreReminder
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setBool:NO forKey:@"SupressAppStoreReminder"];
    if([defaults boolForKey:@"SupressAppStoreReminder"])
        return;
        
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Moving to the App Store"];
    [alert setInformativeText:@"Starting with the next major version CCMenu will only be distributed via the App Store. If you do not switch to the App Store version you will not be notified of future updates. Please go to the App Store now and download CCMenu from there.\n\nCCMenu will remain open source software, and it will remain free. We are focusing on the App Store as a release channel in order to reduce the overhead when publishing new versions of CCMenu."];
    [alert addButtonWithTitle:@"Go to App Store"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setShowsSuppressionButton:YES];

    NSInteger result = [alert runModal];
    if(result == NSAlertFirstButtonReturn)
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"macappstores://itunes.apple.com/us/app/ccmenu/id603117688"]];
    
    if([[alert suppressionButton] state] == NSOnState)
        [defaults setBool:YES forKey:@"SupressAppStoreReminder"];
    
    [alert release];
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
        else
            [self showAppStoreReminder];
    }
	@catch(NSException *e)
	{
		// ignore; if we don't the run-loop might not get set up properly
	}
}

@end
