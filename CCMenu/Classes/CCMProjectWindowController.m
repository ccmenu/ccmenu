
#import "CCMProjectWindowController.h"
#import "CCMServerMonitor.h"


@implementation CCMProjectWindowController

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem 
{
    if([[toolbarItem itemIdentifier] isEqual:@"ForceBuild"]) 
		return ([[tableViewController selectionIndexes] count] > 0);
    return NO;
}

- (void)statusUpdate:(NSNotification *)notification
{	
	[self displayProjects:[[notification object] projects]];
}

- (void)displayProjects:(NSArray *)projects
{
	[tableViewController setContent:projects];
}

- (void)showWindow:(id)sender
{
	if(window == nil)
	{
		[NSBundle loadNibNamed:@"ProjectWindow" owner:self];
		NSToolbar *toolbar = [self createToolbarWithName:@"ProjectWindow"];
		[window setToolbar:toolbar];
		[toolbar setAllowsUserCustomization:YES];
		[toolbar setAutosavesConfiguration:YES];

		[[NSNotificationCenter defaultCenter] 
			addObserver:self selector:@selector(statusUpdate:) name:CCMProjectStatusUpdateNotification object:nil];
	}
	[NSApp activateIgnoringOtherApps:YES];
	[window makeKeyAndOrderFront:self];	
}

- (void)forceBuild:(id)sender
{
	NSRunAlertPanel(nil, @"Force build is not supported yet.", @"OK", nil, nil);
}

@end
