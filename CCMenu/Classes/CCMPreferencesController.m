
#import "CCMPreferencesController.h"
#import "CCMConnection.h"
#import "NSArray+EDExtensions.h"
#import "NSAppleScript+EDAdditions.h"
#import "CCMKeychainHelper.h"
#import "CCMProjectSheetController.h"

#define WINDOW_TITLE_HEIGHT 78


NSString *CCMPreferencesChangedNotification = @"CCMPreferencesChangedNotification";

NSString *CCMProjectTableRowType = @"CCMProjectTableRowType";


@implementation CCMPreferencesController

- (void)showWindow:(id)sender
{
	if(preferencesWindow == nil)
	{
        NSArray *toplevelObjects = nil;
		[[NSBundle mainBundle] loadNibNamed:@"Preferences" owner:self topLevelObjects:&toplevelObjects];
        [toplevelObjects retain];
        [[preferencesWindow standardWindowButton:NSWindowZoomButton] setHidden:YES];
		[preferencesWindow center];
		[preferencesWindow setToolbar:[self createToolbarWithName:@"Preferences"]];
		[[preferencesWindow toolbar] setSelectedItemIdentifier:@"Projects"];
        [projectsTableView registerForDraggedTypes:@[CCMProjectTableRowType]];

		[self switchPreferencesPane:self];
	}
    [soundNamesViewController setContent:[self availableSounds]];
	[NSApp activateIgnoringOtherApps:YES];
	[preferencesWindow makeKeyAndOrderFront:self];	
}

- (void)switchPreferencesPane:(id)sender
{
	NSString *selectedIdentifier = [[preferencesWindow toolbar] selectedItemIdentifier];
	NSUInteger index = [[self toolbarDefaultItemIdentifiers:nil] indexOfObject:selectedIdentifier];
	NSArray *allViews = [NSArray arrayWithObjects:projectsView, notificationPrefsView, advancedPrefsView, nil];
	NSView *prefView = [allViews objectAtIndex:index];
	NSDictionary *itemDef = [[toolbarDefinition objectForKey:@"itemInfoByIdentifier"] objectForKey:selectedIdentifier];
	[preferencesWindow setTitle:[itemDef objectForKey:@"label"]]; 
    
	NSRect windowFrame = [preferencesWindow frame];
	windowFrame.size.height = [prefView frame].size.height + WINDOW_TITLE_HEIGHT;
	windowFrame.size.width = [prefView frame].size.width;
	windowFrame.origin.y = NSMaxY([preferencesWindow frame]) - ([prefView frame].size.height + WINDOW_TITLE_HEIGHT);
	
	if([[paneHolderView subviews] count] > 0)
		[[[paneHolderView subviews] firstObject] removeFromSuperview];
	[preferencesWindow setFrame:windowFrame display:YES animate:(sender != self)];
    
    if(index == 0)
    {
        [preferencesWindow setContentMinSize:NSMakeSize(350, 350)];
        [preferencesWindow setContentMaxSize:NSMakeSize(800, 1200)];
    }
    else
    {
        [preferencesWindow setContentMinSize:[prefView frame].size];
        [preferencesWindow setContentMaxSize:[prefView frame].size];
	}
	[paneHolderView setFrame:[prefView frame]];
	[paneHolderView addSubview:prefView];
}

- (NSDictionary *)selectedProject
{
    NSArray *selectedObjects = [allProjectsViewController selectedObjects];
    return (([selectedObjects count] == 1) ? [selectedObjects objectAtIndex:0] : nil);
}

- (void)addProjects:(id)sender
{
    // slightly naughty but we want to split the XIB files eventually
    [addProjectsController setValue:defaultsManager forKey:@"defaultsManager"];
    [addProjectsController beginAddSheetForWindow:preferencesWindow];
}

- (void)editProject:(id)sender
{
    // slightly naughty but we want to split the XIB files eventually
    [addProjectsController setValue:defaultsManager forKey:@"defaultsManager"];
    [addProjectsController beginEditSheetWithProject:[self selectedProject] forWindow:preferencesWindow];
}

- (void)removeProjects:(id)sender
{
	[allProjectsViewController remove:sender];
	[self preferencesChanged:sender];
}

- (BOOL)tableView:(NSTableView *)tv writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard
{
	[pboard declareTypes:@[CCMProjectTableRowType] owner:self];
    [pboard setPropertyList:rows forType:CCMProjectTableRowType];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{
    if([info draggingSource] != projectsTableView)
        return NSDragOperationNone;
    [tv setDropRow:row dropOperation:NSTableViewDropAbove];
    return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView *)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op
{
    return NO;
}


- (NSArray *)availableSounds
{
    NSMutableArray *sounds = [NSMutableArray arrayWithObject:@"-"];
    for(NSString *libPath in NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSAllDomainsMask, YES)) 
    {
        NSString *soundLibPath = [libPath stringByAppendingPathComponent:@"Sounds"];
        for (NSString *filename in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:soundLibPath error:nil]) 
        {
            if([filename hasPrefix:@"."] == NO)
                [sounds addObject:[filename stringByDeletingPathExtension]];
        }
    }
    return sounds;
}

- (void)soundSelected:(id)sender
{
    [[NSSound soundNamed:[sender title]] play];
}

#ifndef CCM_MAS_BUILD
- (IBAction)openNotificationPreferences:(id)sender
{
    [[NSAppleScript scriptWithName:@"handlers"] callHandler:@"open_notifications"];
}

- (IBAction)updateIntervalChanged:(id)sender
{
	[updater setUpdateCheckInterval:(NSTimeInterval)[sender selectedTag]];
}

- (IBAction)checkForUpdateNow:(id)sender
{
    [updater checkForUpdates:sender];
}
#endif

- (void)preferencesChanged:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CCMPreferencesChangedNotification object:sender];
}

@end
