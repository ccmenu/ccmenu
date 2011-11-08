
#import <EDCommon/EDCommon.h>
#import "NSObject+CCMAdditions.h"
#import "NSCalendarDate+CCMAdditions.h"
#import "CCMStatusItemMenuController.h"
#import "CCMImageFactory.h"
#import "CCMServerMonitor.h"
#import "CCMProject.h"

@interface NSStatusItem(MyTitleFormatting)

- (void)setFormattedTitle:(NSString *)aTitle;

@end

@implementation NSStatusItem(MyTitleFormatting)

- (void)setFormattedTitle:(NSString *)aTitle
{
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    [attr setObject:[NSFont fontWithName:@"Lucida Grande" size:12] forKey:NSFontAttributeName];
    NSAttributedString *strg = [[[NSAttributedString alloc] initWithString:aTitle attributes:attr] autorelease];
    [self setAttributedTitle:strg];
}

@end


@implementation CCMStatusItemMenuController

- (void)awakeFromNib
{
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];	
	[statusItem setImage:[imageFactory imageForUnavailableServer]];
	[statusItem setHighlightMode:YES];
	[statusItem setMenu:statusMenu];
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self selector:@selector(displayProjects:) name:CCMProjectStatusUpdateNotification object:nil];
}

- (NSStatusItem *)statusItem
{
    return statusItem;
}


- (CCMProject *)projectForStatusBar:(NSArray *)projectList
{
    NSSortDescriptor *status = [NSSortDescriptor sortDescriptorWithKey:@"hasStatus" ascending:NO];
    NSSortDescriptor *building = [NSSortDescriptor sortDescriptorWithKey:@"isBuilding" ascending:NO];
    NSSortDescriptor *failed = [NSSortDescriptor sortDescriptorWithKey:@"isFailed" ascending:NO];
    NSSortDescriptor *timing = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES comparator:^(id obj1, id obj2) {
        // custom comparator using nil key path to work around sorting nil values
        // http://stackoverflow.com/questions/2021213/nssortdescriptor-and-nil-values
        // http://www.cocoabuilder.com/archive/cocoa/283958-nssortdescriptor-and-block.html        
        NSDate *val1 = [[obj1 getWithDefault:[NSDate distantFuture]] estimatedBuildCompleteTime];
        NSDate *val2 = [[obj2 getWithDefault:[NSDate distantFuture]] estimatedBuildCompleteTime];
        return [val1 compare:val2];
    }];
    
    NSArray *descriptors = [NSArray arrayWithObjects:status, building, failed, timing, nil];
    NSArray *sortedProjectList = [projectList sortedArrayUsingDescriptors:descriptors];
    return [sortedProjectList firstObject];
}

- (void)setupStatusItem:(NSStatusItem *)item forProject:(CCMProject *)project fromList:(NSArray *)projectList
{
    if((project == nil) || ([project status] == nil))
    {
		[item setImage:[imageFactory imageForActivity:nil lastBuildStatus:nil]];
		[item setTitle:@""];
    } 
    else if([project isBuilding] == NO)
    {
        NSString *status = [project isFailed] ? CCMFailedStatus : CCMSuccessStatus;
		[item setImage:[imageFactory imageForActivity:CCMSleepingActivity lastBuildStatus:status]];
        NSString *text = @"";
        if([project isFailed])
        {
            __block int failCount = 0;
            [projectList enumerateObjectsUsingBlock:^(id project, NSUInteger idx, BOOL *stop) {
                if([project isFailed])
                    failCount += 1;
            }];
            text = [NSString stringWithFormat:@"%u", failCount];
        }
        [item setFormattedTitle:text];
    }
    else
    {
		NSString *status = [project isFailed] ? CCMFailedStatus : CCMSuccessStatus;
		[item setImage:[imageFactory imageForActivity:CCMBuildingActivity lastBuildStatus:status]];
        NSString *text = @"";
        NSCalendarDate *estimatedComplete = [project estimatedBuildCompleteTime];
		if(estimatedComplete != nil)
        {
            text = [[NSCalendarDate date] descriptionOfIntervalSinceDate:estimatedComplete withSign:YES];
        }
        [item setFormattedTitle:text];
    }
}

- (void)setupMenu:(NSMenu *)menu forProjects:(NSArray *)projectList
{	
	int index = 0;
    for(CCMProject *project in [projectList sortedArrayByComparingAttribute:@"name"])
    {
        NSMenuItem *menuItem = [[menu itemArray] objectAtIndex:index];
        while(([menuItem isSeparatorItem] == NO) && ([[project name] compare:[menuItem title]] == NSOrderedDescending))
        {
            [menu removeItemAtIndex:index];
            menuItem = [[menu itemArray] objectAtIndex:index];
        }
        if([menuItem representedObject] != project)
        {
            menuItem = [menu insertItemWithTitle:[project name] action:@selector(openProject:) keyEquivalent:@"" atIndex:index];
            [menuItem setTarget:self];
            [menuItem setRepresentedObject:project];
        }
		NSImage *image = [imageFactory imageForActivity:[[project status] activity] lastBuildStatus:[[project status] lastBuildStatus]];
		[menuItem setImage:[imageFactory convertForMenuUse:image]];
        index += 1;
    }
    while([[[menu itemArray] objectAtIndex:index] isSeparatorItem] == NO)
    {
        [menu removeItemAtIndex:index];
    }
}


- (void)displayProjects:(id)sender
{
    NSArray *projectList = [serverMonitor projects];
	[self setupMenu:[statusItem menu] forProjects:projectList];
    
    CCMProject *project = [self projectForStatusBar:projectList];
    [self setupStatusItem:statusItem forProject:project fromList:projectList];
    
    if([project isBuilding])
    {
        [timer invalidate];
        [timer release];
        timer = [[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(displayProjects:) userInfo:nil repeats:NO] retain];
    }
}


- (IBAction)openProject:(id)sender
{
    CCMProject *project = [sender representedObject];
	if([[project status] webUrl] != nil)
    {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[project status] webUrl]]];
    }
    else
	{
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		if([project statusError] != nil) 
		{
			[alert setMessageText:NSLocalizedString(@"An error occured when retrieving the project status", "Alert message when an error occured talking to the server.")];
			[alert setInformativeText:[project statusError]];
		}
		else
		{
			[alert setMessageText:NSLocalizedString(@"Cannot open web page", "Alert message when server does not provide webUrl")];
			[alert setInformativeText:NSLocalizedString(@"This continuous integration server does not provide web URLs for projects. Please contact the server administrator.", "Informative text when server does not provide webUrl")];
		}
		[alert runModal];
	}
}

@end
