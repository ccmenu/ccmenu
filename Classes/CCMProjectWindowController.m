
#import "CCMProjectWindowController.h"
#import "CCMServerMonitor.h"


@implementation CCMProjectWindowController

- (void)showWindow:(id)sender
{
	if(projectController == nil)
		[NSBundle loadNibNamed:@"ProjectWindow" owner:self];
	
	[window makeKeyAndOrderFront:self];

	[[NSNotificationCenter defaultCenter] 
		addObserver:self selector:@selector(statusUpdate:) name:CCMProjectStatusUpdateNotification object:nil];
}

- (void)statusUpdate:(NSNotification *)notification
{	
	[self displayProjectInfos:[[notification object] getProjectInfos]];
}

- (void)displayProjectInfos:(NSArray *)projectInfos
{
	[projectController setSortDescriptors:nil];
	[projectController setContent:projectInfos];
}


@end
