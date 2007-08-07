
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
	[statusItem setImage:[imageFactory imageForUnavailableServer]];
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
	unsigned buildCount = 0;
	bool isFixing = NO;
	NSEnumerator *projectEnum = [projectList objectEnumerator];
	CCMProject *project;
	while((project = [projectEnum nextObject]) != nil)
	{
		NSString *title = [NSString stringWithFormat:@"%@", [project name]];
		NSMenuItem *menuItem = [menu insertItemWithTitle:title action:@selector(openProject:) keyEquivalent:@"" atIndex:index++];
		NSImage *image = [imageFactory imageForActivity:[project valueForKey:@"activity"] 
										lastBuildStatus:[project valueForKey:@"lastBuildStatus"]];
		image = [imageFactory convertForMenuUse:image];
		[menuItem setImage:image];
		if([project isFailed])
			failCount += 1;
		if([project isBuilding])
			buildCount += 1;
		if([project isBuilding] && [project isFailed])
			isFixing = YES;
		[menuItem setTarget:self];
		[menuItem setRepresentedObject:project];
	}
	if(buildCount > 0)
	{
		NSString *status = isFixing ? CCMFailedStatus : CCMSuccessStatus;
		[statusItem setImage:[imageFactory imageForActivity:CCMBuildingActivity lastBuildStatus:status]];
		[statusItem setTitle:@""];
	}
	else if(failCount > 0)
	{
		[statusItem setImage:[imageFactory imageForActivity:nil lastBuildStatus:CCMFailedStatus]];
		[statusItem setTitle:[NSString stringWithFormat:@"%u", failCount]];
	}
	else
	{
		[statusItem setImage:[imageFactory imageForActivity:nil lastBuildStatus:CCMSuccessStatus]];
		[statusItem setTitle:@""];
	}
}

- (void)statusUpdate:(NSNotification *)notification
{	
	[self displayProjects:[[notification object] projects]];
}

- (IBAction)openProject:(id)sender
{
	NSString *urlString = [[sender representedObject] valueForKey:@"webUrl"];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
}

@end
