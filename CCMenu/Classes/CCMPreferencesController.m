
#import "CCMPreferencesController.h"
#import "CCMConnection.h"
#import "NSArray+EDExtensions.h"
#import "CCMKeychainHelper.h"
#import "CCMProjectSheetController.h"

#define WINDOW_TITLE_HEIGHT 78


NSString *CCMPreferencesChangedNotification = @"CCMPreferencesChangedNotification";


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
		[self switchPreferencesPane:self];
	}
    [soundNamesViewController setContent:[self availableSounds]];
    if([defaultsManager shouldShowAppIconWhenInPrefs])
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [NSApp activateIgnoringOtherApps:YES];
	[preferencesWindow makeKeyAndOrderFront:self];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
}


- (void)switchPreferencesPane:(id)sender
{
	NSString *selectedIdentifier = [[preferencesWindow toolbar] selectedItemIdentifier];
	NSUInteger index = [[self toolbarDefaultItemIdentifiers:[preferencesWindow toolbar]] indexOfObject:selectedIdentifier];
	NSArray *allViews = [NSArray arrayWithObjects:projectsView, notificationPrefsView, appearanceView, advancedPrefsView, nil];
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

- (NSArray *)availableSounds
{
    NSMutableArray *sounds = [NSMutableArray array];
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

- (void)preferencesChanged:(id)sender
{
    if([defaultsManager shouldUseColorInMenuBar] == NO)
        [defaultsManager setShouldUseSymbolsForAllStatesInMenuBar:YES];

    [[NSNotificationCenter defaultCenter] postNotificationName:CCMPreferencesChangedNotification object:sender];
}

- (void)activationPolicyChanged:(id)sender
{
    if([defaultsManager shouldShowAppIconWhenInPrefs])
    {
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    }
    else
    {
        [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
        // unfortunately this also deactivates our app, hiding the window in the process. so...
        [self performSelector:@selector(reactivate:) withObject:self afterDelay:0];
    }
}

- (void)reactivate:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
}

@end
