
#import "CCMStatusBarMenuController.h"
#import "CCMImageFactory.h"
#import "CCMServerMonitor.h"
#import "CCMProject.h"

@implementation CCMStatusBarMenuController

static const int PROJECT_LIST_SEPARATOR_TAG = 7;

- (void)setMenu:(NSMenu *)aMenu
{
	statusMenu = aMenu;
}

- (void)setImageFactory:(CCMImageFactory *)anImageFactory
{
	[imageFactory autorelease];
	imageFactory = [anImageFactory retain];
}

- (void)awakeFromNib
{
	[self createStatusItem];
	[[NSNotificationCenter defaultCenter] 
		addObserver:self selector:@selector(statusUpdate:) name:CCMProjectStatusUpdateNotification object:nil];
}

- (NSStatusItem *)createStatusItem
{
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];	
	[statusItem setImage:[imageFactory getImageForStatus:@"Inactive"]];
	[statusItem setHighlightMode:YES];
	[statusItem setMenu:statusMenu];
	return statusItem;
}

- (void)displayProjects:(NSArray *)projectList
{
	NSMenu *menu = [statusItem menu];
	
	int index = [menu indexOfItemWithTag:PROJECT_LIST_SEPARATOR_TAG] + 1;
	while([[[menu itemArray] objectAtIndex:index] isSeparatorItem] == FALSE)
		[menu removeItemAtIndex:index];
	
	unsigned failCount = 0;
	NSEnumerator *projectEnum = [projectList objectEnumerator];
	CCMProject *project;
	while((project = [projectEnum nextObject]) != nil)
	{
		NSString *title = [NSString stringWithFormat:@"%@", [project name]];
		NSMenuItem *menuItem = [menu insertItemWithTitle:title action:@selector(openProject:) keyEquivalent:@"" atIndex:index++];
		[menuItem setImage:[imageFactory getImageForStatus:[project valueForKey:@"lastBuildStatus"]]];
		if([project isFailed])
			failCount += 1;
		[menuItem setTarget:self];
		[menuItem setRepresentedObject:[project valueForKey:@"webUrl"]];
	}
	NSImage *image = [imageFactory getImageForStatus:(failCount == 0) ? CCMPassedStatus : CCMFailedStatus];
	[statusItem setImage:image];
	if(failCount > 0)
		[statusItem setTitle:[NSString stringWithFormat:@"%u", failCount]];
	else
		[statusItem setTitle:@""];
}

- (void)statusUpdate:(NSNotification *)notification
{	
	[self displayProjects:[[notification object] projects]];
}

- (IBAction)openProject:(id)sender
{
	NSURL *url = [NSURL URLWithString:[sender representedObject]];
	[[NSWorkspace sharedWorkspace] openURL:url];
}

@end
