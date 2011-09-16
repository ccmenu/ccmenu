
#import "CCMProjectWindowController.h"
#import "CCMServerMonitor.h"


@implementation CCMProjectWindowController

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem 
{
    if([[toolbarItem itemIdentifier] isEqual:@"ForceBuild"]) 
		return ([[tableViewController selectionIndexes] count] > 0);
    return NO;
}

- (void)showWindow:(id)sender
{
	if(window == nil)
    {
		[NSBundle loadNibNamed:@"ProjectWindow" owner:self];
		[[NSNotificationCenter defaultCenter] 
         addObserver:self selector:@selector(displayProjects:) name:CCMProjectStatusUpdateNotification object:nil];
    }

    [self displayProjects:self];
    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(displayProjects:) userInfo:nil repeats:YES];

	[NSApp activateIgnoringOtherApps:YES];
	[window makeKeyAndOrderFront:self];	
}

- (void)windowWillClose:(NSNotification *)notification
{
    [timer invalidate];
}

- (void)displayProjects:(id)sender
{
    NSArray *projects = [serverMonitor projects];
	[tableViewController setContent:projects];
}


@end
