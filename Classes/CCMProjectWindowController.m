
#import "CCMProjectWindowController.h"
#import "CCMServerMonitor.h"

NSString *CCMProjectWindowToolBar = @"CCMProjectWindowToolBar";
NSString *CCMForceBuildToolBarIdentifier = @"CCMForceBuildToolBarIdentifier";


@implementation CCMProjectWindowController

- (NSToolbar *)createToolbar
{
    NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier: CCMProjectWindowToolBar] autorelease];
    [toolbar setAllowsUserCustomization: YES];
    [toolbar setAutosavesConfiguration: YES];
    [toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
    [toolbar setDelegate:self];
	return toolbar;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)identifier willBeInsertedIntoToolbar:(BOOL)willBeInserted 
{
    NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:identifier] autorelease];
    
    if([identifier isEqual:CCMForceBuildToolBarIdentifier])
	{
		[toolbarItem setLabel:@"Force Build"];
		[toolbarItem setPaletteLabel:@"Force Build"];
		[toolbarItem setToolTip: @"Force build of selected projects"];
		[toolbarItem setImage: [NSImage imageNamed:@"icon-force-build"]];
		[toolbarItem setTarget:self];
		[toolbarItem setAction: @selector(forceBuild:)];
	} 
	else 
	{
		toolbarItem = nil;
    }
    return toolbarItem;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar 
{
    return [NSArray arrayWithObjects:CCMForceBuildToolBarIdentifier, nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar 
{
    return [NSArray arrayWithObjects:CCMForceBuildToolBarIdentifier, 
		NSToolbarCustomizeToolbarItemIdentifier, NSToolbarFlexibleSpaceItemIdentifier, 
		NSToolbarSpaceItemIdentifier, NSToolbarSeparatorItemIdentifier, nil];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem 
{
    if([[toolbarItem itemIdentifier] isEqual:CCMForceBuildToolBarIdentifier]) 
		return ([[projectController selectionIndexes] count] > 0);
    return NO;
}

- (void)statusUpdate:(NSNotification *)notification
{	
	[self displayProjectInfos:[[notification object] projects]];
}

- (void)displayProjectInfos:(NSArray *)projectInfos
{
	[projectController setContent:projectInfos];
}

- (void)showWindow:(id)sender
{
	if(window == nil)
	{
		[NSBundle loadNibNamed:@"ProjectWindow" owner:self];
		[window setToolbar:[self createToolbar]];
	}
	
	[window makeKeyAndOrderFront:self];
	
	[[NSNotificationCenter defaultCenter] 
		addObserver:self selector:@selector(statusUpdate:) name:CCMProjectStatusUpdateNotification object:nil];
}

- (void)forceBuild:(id)sender
{
}



@end
