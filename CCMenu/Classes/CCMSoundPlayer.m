
#import "CCMSoundPlayer.h"
#import "CCMServerMonitor.h"


@implementation CCMSoundPlayer

- (void)start
{
	[[NSNotificationCenter defaultCenter] 
     addObserver:self selector:@selector(buildComplete:) name:CCMBuildCompleteNotification object:nil];
}

- (void)buildComplete:(NSNotification *)notification
{
    NSString *result = [[notification userInfo] objectForKey:@"buildResult"];
    NSString *defaultName = [NSString stringWithFormat:@"Sound %@", result]; // slightly naughty
    NSString *soundName = [[NSUserDefaults standardUserDefaults] stringForKey:defaultName];
    if(soundName != nil)
        [[NSSound soundNamed:soundName] play];
}

@end
