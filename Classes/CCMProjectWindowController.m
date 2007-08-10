
#import "CCMProjectWindowController.h"
#import "CCMServerMonitor.h"

NSString *CCMProjectWindowToolBar = @"CCMProjectWindowToolBar";
NSString *CCMForceBuildToolBarIdentifier = @"CCMForceBuildToolBarIdentifier";
NSString *CCMSettingsToolBarIdentifier = @"CCMSettingsToolBarIdentifier";


@implementation CCMProjectWindowController

- (NSToolbar *)createToolbar
{
    NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier: CCMProjectWindowToolBar] autorelease];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
    [toolbar setDelegate:self];
	return toolbar;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)identifier willBeInsertedIntoToolbar:(BOOL)willBeInserted 
{
    NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:identifier] autorelease];
    
	// TODO: Maybe we should use something like EDToolbarDefinition here
    if([identifier isEqual:CCMForceBuildToolBarIdentifier])
	{
		[toolbarItem setLabel:@"Force Build"];
		[toolbarItem setPaletteLabel:@"Force Build"];
		[toolbarItem setToolTip: @"Force build of selected projects"];
		[toolbarItem setImage: [NSImage imageNamed:@"Placeholder"]];
		[toolbarItem setTarget:self];
		[toolbarItem setAction: @selector(forceBuild:)];
	} 
	else if([identifier isEqual:CCMSettingsToolBarIdentifier])
	{
		[toolbarItem setLabel:@"Settings"];
		[toolbarItem setPaletteLabel:@"Settings"];
		[toolbarItem setToolTip: @"Edit settings"];
		[toolbarItem setImage: [NSImage imageNamed:@"Placeholder"]];
		[toolbarItem setTarget:self];
		[toolbarItem setAction: @selector(editSettings:)];
	}
	else
	{
		toolbarItem = nil;
    }
    return toolbarItem;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar 
{
    return [NSArray arrayWithObjects:CCMForceBuildToolBarIdentifier, NSToolbarFlexibleSpaceItemIdentifier, 
		CCMSettingsToolBarIdentifier, nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar 
{
    return [NSArray arrayWithObjects:CCMForceBuildToolBarIdentifier, CCMSettingsToolBarIdentifier,
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
	[self displayProjects:[[notification object] projects]];
}

- (void)displayProjects:(NSArray *)projects
{
	[projectController setContent:projects];
}

- (void)showWindow:(id)sender
{
	if(window == nil)
	{
		[NSBundle loadNibNamed:@"ProjectWindow" owner:self];
		[window setToolbar:[self createToolbar]];

		[[NSNotificationCenter defaultCenter] 
			addObserver:self selector:@selector(statusUpdate:) name:CCMProjectStatusUpdateNotification object:nil];
	}
	[window makeKeyAndOrderFront:self];	
}

- (void)forceBuild:(id)sender
{
	NSRunAlertPanel(nil, @"Force build does not work yet", @"OK", nil, nil);
}

- (void)editSettings:(id)sender
{
}

@end
