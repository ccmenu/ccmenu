
#import "CCMStatusBarMenuController.h"
#import "CCMServerMonitor.h"
#import "CCMProjectInfo.h"

@implementation CCMStatusBarMenuController

static const int PROJECT_LIST_SEPARATOR_TAG = 7;

- (void)setMenu:(NSMenu *)aMenu
{
	statusMenu = aMenu;
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
	[statusItem setImage:[self getImageForStatus:@"Inactive"]];
	[statusItem setHighlightMode:YES];
	[statusItem setMenu:statusMenu];
	return statusItem;
}

- (void)displayProjectInfos:(NSArray *)projectInfos
{
	NSMenu *menu = [statusItem menu];
	
	int index = [menu indexOfItemWithTag:PROJECT_LIST_SEPARATOR_TAG] + 1;
	while([[[menu itemArray] objectAtIndex:index] isSeparatorItem] == FALSE)
		[menu removeItemAtIndex:index];
	
	unsigned failCount = 0;
	NSEnumerator *infoEnum = [projectInfos objectEnumerator];
	CCMProjectInfo *info;
	while((info = [infoEnum nextObject]) != nil)
	{
		NSString *title = [NSString stringWithFormat:@"%@ (%@)", [info projectName], [info timeSinceLastBuild]];
		NSMenuItem *menuItem = [menu insertItemWithTitle:title action:@selector(openProject:) keyEquivalent:@"" atIndex:index++];
		[menuItem setImage:[self getImageForStatus:[info buildStatus]]];
		if([info isFailed])
			failCount += 1;
		[menuItem setTarget:self];
	}
	NSImage *image = [self getImageForStatus:(failCount == 0) ? CCMPassedStatus : CCMFailedStatus];
	[statusItem setImage:image];
	if(failCount > 0)
		[statusItem setTitle:[NSString stringWithFormat:@"%u", failCount]];
	else
		[statusItem setTitle:@"-0:12:39"];
}

- (NSImage *)getImageForStatus:(NSString *)status
{
	NSString *name = [NSString stringWithFormat:@"icon-%@.gif", [status lowercaseString]];
	NSImage *image = [NSImage imageNamed:name];
	[image setScalesWhenResized:YES];
	[image setSize:NSMakeSize(13, 13)];
	return image;
}

- (void)statusUpdate:(NSNotification *)notification
{	
	NSArray *infos = [[notification object] getProjectInfos];
	[self displayProjectInfos:infos];
}

- (IBAction)openProject:(id)sender
{
	NSURL *url = [NSURL URLWithString:@"http://localhost:8080/dashboard"];
	[[NSWorkspace sharedWorkspace] openURL:url];
}

@end
