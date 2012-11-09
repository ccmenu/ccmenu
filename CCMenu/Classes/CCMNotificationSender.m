
#import "CCMServerMonitor.h"
#import "CCMNotificationSender.h"


struct {
	NSString *key;
	NSString *title;
	NSString *text;
} notifications[5];


@implementation CCMNotificationSender

+ (void)initialize
{
	notifications[0].key = CCMSuccessfulBuild;
	notifications[0].title = NSLocalizedString(@"Success", "Notification for successful build");
	notifications[0].text = NSLocalizedString(@"Yet another successful build!", "For notificiation");
    
	notifications[1].key = CCMStillFailingBuild;
	notifications[1].title = NSLocalizedString(@"Still broken", "Growl notification for successful build");
	notifications[1].text = NSLocalizedString(@"The build is still broken.", "For notificiation");
	
	notifications[2].key = CCMBrokenBuild;
	notifications[2].title = NSLocalizedString(@"Broken", "Notification for successful build");
	notifications[2].text = NSLocalizedString(@"Recent checkins have broken the build.", "For notificiation");
    
	notifications[3].key = CCMFixedBuild;
	notifications[3].title = NSLocalizedString(@"Fixed", "Notification for successful build");
	notifications[3].text = NSLocalizedString(@"Recent checkins have fixed the build.", "For notificiation");
}	

- (void)start
{
	[[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(buildComplete:) name:CCMBuildCompleteNotification object:nil];
}

- (void)buildComplete:(NSNotification *)buildNotification
{
	NSString *projectName = [[buildNotification object] name];
	NSString *buildResult = [[buildNotification userInfo] objectForKey:@"buildResult"];
    
	for(int i = 0; notifications[i].key != nil; i++)
	{
		if([buildResult isEqualToString:notifications[i].key])
		{
            NSUserNotification *userNotification = [[NSUserNotification alloc] init];
            
            userNotification.title = [NSString stringWithFormat:@"%@: %@", projectName, notifications[i].title];
            userNotification.informativeText = notifications[i].text;
            
            NSString *defaultName = [NSString stringWithFormat:@"Sound %@", buildResult]; // slightly naughty
            NSString *soundName = [[NSUserDefaults standardUserDefaults] stringForKey:defaultName];
            if(![soundName isEqualToString:@"-"])
                userNotification.soundName = soundName;

            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:userNotification];
			break;
		}
	}
}

@end
