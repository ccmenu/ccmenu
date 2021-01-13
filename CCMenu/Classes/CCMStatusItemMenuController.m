
#import "NSObject+CCMAdditions.h"
#import "NSDate+CCMAdditions.h"
#import "CCMStatusItemMenuController.h"
#import "NSWorkspace+CCMAdditions.h"

@interface NSStatusItem(MyTitleFormatting)

- (void)setFormattedTitle:(NSString *)aTitle;

@end

@implementation NSStatusItem(MyTitleFormatting)

- (void)setFormattedTitle:(NSString *)aTitle
{
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    CGFloat size = [[NSFont menuBarFontOfSize:0] pointSize];
    NSFont *font = [NSFont monospacedDigitSystemFontOfSize:size weight:NSFontWeightRegular];
    [attr setObject:font forKey:NSFontAttributeName];
    NSAttributedString *strg = [[[NSAttributedString alloc] initWithString:aTitle attributes:attr] autorelease];
    [[self button] setAttributedTitle:strg];
}

@end


@implementation CCMStatusItemMenuController

- (void)awakeFromNib
{
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];	
    [[statusItem button] setImage:[imageFactory imageForUnavailableServer]];
    [[[statusItem button] cell] setImagePosition:NSImageLeft];
	[statusItem setMenu:statusMenu];
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self selector:@selector(displayProjects:) name:CCMProjectStatusUpdateNotification object:nil];
}

- (NSStatusItem *)statusItem
{
    return statusItem;
}


- (int)statusPriorityForStatus:(CCMProjectStatus *)status
{
    if(status == nil)
        return 0;
    else if([status buildDidFail])
        return 3;
    else if([status buildWasSuccessful])
        return 2;
    else
        return 1;
}


- (CCMProject *)projectForStatusBar:(NSArray *)projectList
{
    NSSortDescriptor *hasStatus = [NSSortDescriptor sortDescriptorWithKey:@"hasStatus" ascending:NO];
    NSSortDescriptor *building = [NSSortDescriptor sortDescriptorWithKey:@"status.isBuilding" ascending:NO];
    NSSortDescriptor *status = [NSSortDescriptor sortDescriptorWithKey:@"status" ascending:NO comparator:^(CCMProjectStatus *s1, CCMProjectStatus *s2) {
        return (NSComparisonResult)([self statusPriorityForStatus:s1] - [self statusPriorityForStatus:s2]);
    }];
    NSSortDescriptor *timing = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES comparator:^(id obj1, id obj2) {
        // custom comparator using nil key path to work around sorting nil values
        // http://stackoverflow.com/questions/2021213/nssortdescriptor-and-nil-values
        // http://www.cocoabuilder.com/archive/cocoa/283958-nssortdescriptor-and-block.html        
        NSDate *val1 = [[obj1 getWithDefault:[NSDate distantFuture]] estimatedBuildCompleteTime];
        NSDate *val2 = [[obj2 getWithDefault:[NSDate distantFuture]] estimatedBuildCompleteTime];
        return [val1 compare:val2];
    }];
    
    NSArray *descriptors = [NSArray arrayWithObjects:hasStatus, building, status, timing, nil];
    NSArray *sortedProjectList = [projectList sortedArrayUsingDescriptors:descriptors];
    return [sortedProjectList firstObject];
}

- (void)setupStatusItem:(NSStatusItem *)item forProject:(CCMProject *)project fromList:(NSArray *)projectList
{
    if((project == nil) || ([project status] ==nil))
    {
        [[item button] setImage:[imageFactory imageForUnavailableServer]];
        [[item button] setTitle:@""];
    }
    else if([[project status] isBuilding] == NO)
    {
        [[item button] setImage:[imageFactory imageForStatus:[project status]]];
        NSString *text = @"";
        if([[project status] buildDidFail])
        {
            __block int failCount = 0;
            [projectList enumerateObjectsUsingBlock:^(CCMProject *project, NSUInteger idx, BOOL *stop) {
                if([[project status] buildDidFail])
                    failCount += 1;
            }];
            text = [NSString stringWithFormat:@"%u", failCount];
        }
        [item setFormattedTitle:text];
    }
    else
    {
        [[item button] setImage:[imageFactory imageForStatus:[project status]]];
        NSString *text = @"";
        if([defaultsManager shouldShowTimerInMenu])
        {
            NSDate *estimatedComplete = [project estimatedBuildCompleteTime];
            if(estimatedComplete != nil)
            {
                text = [[NSDate date] descriptionOfIntervalSinceDate:estimatedComplete withSign:YES];
                if([text length] == 3)
                    text = [text stringByAppendingString:@"  "];
            }
        }
        [item setFormattedTitle:text];
    }
}

- (void)setupMenu:(NSMenu *)menu forProjects:(NSArray *)fullProjectList
{
    NSArray *projectList = [self filterAndSortProjectList:fullProjectList];

    NSUInteger index = 0;
    for(CCMProject *project in projectList)
    {
        [self addProject:project toMenu:menu atIndex:index++];
    }
    while([[[menu itemArray] objectAtIndex:index] isSeparatorItem] == NO)
    {
        [menu removeItemAtIndex:index];
    }
    NSUInteger hiddenCount = [fullProjectList count] - [projectList count];
    if(hiddenCount > 0)
    {
        [self addHiddenProjectsHintWithCount:hiddenCount toMenu:menu atIndex:index];
    }
}

- (NSArray *)filterAndSortProjectList:(NSArray *)projectList
{
    if([defaultsManager shouldHideSuccessfulBuilds])
    {
        projectList = [projectList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status == %@ OR status.buildWasSuccessful == %@", nil, @NO]];
    }
    switch([defaultsManager projectOrder])
    {
        case CCMProjectOrderAlphabetic:
            projectList = [projectList sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES selector:@selector(caseInsensitiveCompare:)]]];
            break;
        case CCMProjectOrderByBuildTime:
            projectList = [projectList sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"status.lastBuildTime" ascending:NO]]];
            break;
        default:
            break;
    }
    return projectList;
}

- (void)addProject:(CCMProject *)project toMenu:(NSMenu *)menu atIndex:(NSUInteger)index
{
    NSMenuItem *menuItem = [[menu itemArray] objectAtIndex:index];
    if([menuItem representedObject] != project)
    {
        menuItem = [menu insertItemWithTitle:@"[new item]" action:@selector(openProject:) keyEquivalent:@"" atIndex:index];
        [menuItem setTarget:self];
        [menuItem setRepresentedObject:project];
    }

    NSString *title = [project displayName];
    NSMutableArray *infoTexts = [NSMutableArray array];
    if([defaultsManager shouldShowLastBuildLabel])
    {
        NSString *lbl = [[project status] lastBuildLabel];
        if(lbl != nil)
        {
            [infoTexts addObject:lbl];
        }
    }
    if([defaultsManager shouldShowLastBuildTimes])
    {
        NSDate *lbt = [[project status] lastBuildTime];
        if(lbt != nil)
            [infoTexts addObject:[lbt descriptionRelativeToNow]];
    }
    if([infoTexts count] > 0)
    {
        title = [title stringByAppendingFormat:@" \u2014 %@", [infoTexts componentsJoinedByString:@", "]];
    }
    [menuItem setTitle:title];

    NSImage *image = [imageFactory imageForStatus:[project status]];
    [menuItem setImage:[imageFactory convertForMenuUse:image]];
}


- (void)addHiddenProjectsHintWithCount:(NSUInteger)hiddenCount toMenu:(NSMenu *)menu atIndex:(NSUInteger)index
{
    NSString *title = [NSString stringWithFormat:@"(%lu %@ not shown)", hiddenCount, (hiddenCount == 1) ? @"project" : @"projects"];
    id menuItem = [menu insertItemWithTitle:title action:NULL keyEquivalent:@"" atIndex:index];
    [menuItem setEnabled:NO];
}


- (void)displayProjects:(id)sender
{
    NSArray *projectList = [serverMonitor projects];
	[self setupMenu:[statusItem menu] forProjects:projectList];
    
    CCMProject *project = [self projectForStatusBar:projectList];
    [self setupStatusItem:statusItem forProject:project fromList:projectList];

    if([[project status] isBuilding])
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
        [[NSWorkspace sharedWorkspace] openURLString:[[project status] webUrl]];
    }
    else
	{
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		if([project statusError] != nil) 
		{
			[alert setMessageText:NSLocalizedString(@"An error occurred when retrieving the project status", "Alert message when an error occured talking to the server.")];
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
