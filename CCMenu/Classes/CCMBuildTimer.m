
#import "CCMBuildTimer.h"
#import "CCMProject.h"
#import "CCMServerMonitor.h"


@implementation CCMBuildTimer

- (id)init
{
    [super init];
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}


- (void)start
{
	[[NSNotificationCenter defaultCenter] 
     addObserver:self selector:@selector(buildStart:) name:CCMBuildStartNotification object:nil];
	[[NSNotificationCenter defaultCenter] 
     addObserver:self selector:@selector(buildComplete:) name:CCMBuildCompleteNotification object:nil];
}


- (void)buildStart:(NSNotification *)notification
{
    CCMProject *project = [notification object];
    [project setBuildStartTime:[NSDate date]];
    NSLog(@"Starting build of %@ at %@", [project name], [project buildStartTime]);
}

- (void)buildComplete:(NSNotification *)notification
{
    CCMProject *project = [notification object];
    NSDate *startTime = [project buildStartTime];
    if(startTime == nil) 
        return;
    
    NSTimeInterval difference = [startTime timeIntervalSinceNow] * -1;
    [project setBuildStartTime:nil];
    if(difference < 12 * 3600) // 12 hours should be enough for any build...
        [project setBuildDuration:difference];
    NSLog(@"Completed build of %@ after %g seconds", [project name], [project buildDuration]);
}

@end
