
#import "CCMPreferencesController.h"
#import "CCMConnection.h"


@implementation CCMPreferencesController

- (NSURL *)getServerURL
{
	NSString *serverUrl = [serverUrlComboBox stringValue];
	if(![serverUrl hasPrefix:@"http://"])
	{
		serverUrl = [@"http://" stringByAppendingString:serverUrl];
		[serverUrlComboBox setStringValue:serverUrl];
	}
	NSArray *allFilenames = [NSArray arrayWithObjects:@"cctray.xml", @"xml.jsp", @"XmlServerReport.aspx", @"??", @"", nil];
	NSString *filename = [allFilenames objectAtIndex:[[serverTypeMatrix selectedCell] tag]];
	if(([serverUrl length] > 0) && (![serverUrl hasSuffix:filename]))
	{
		if(![serverUrl hasSuffix:@"/"])
			serverUrl = [serverUrl stringByAppendingString:@"/"];
		serverUrl = [serverUrl stringByAppendingString:filename];
	}
	return [NSURL URLWithString:serverUrl];
}

- (void)showWindow:(id)sender
{
	if(preferencesWindow == nil)
	{
		[NSBundle loadNibNamed:@"Preferences" owner:self];
	}
	[preferencesWindow makeKeyAndOrderFront:self];	
}

- (IBAction)addProjects:(id)sender
{
	[sheetTabView selectFirstTabViewItem:self];
	[NSApp beginSheet:addProjectsSheet modalForWindow:preferencesWindow modalDelegate:self 
		didEndSelector:@selector(addProjectsSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)chooseProjects:(id)sender
{
	@try 
	{
		[testServerProgressIndicator startAnimation:self];
		CCMConnection *connection = [[[CCMConnection alloc] initWithURL:[self getServerURL]] autorelease];
		NSArray *projectInfos = [connection getProjectInfos];
		[testServerProgressIndicator stopAnimation:self];
		[chooseProjectsViewController setContent:projectInfos];
		[sheetTabView selectNextTabViewItem:self];
	}
	@catch (NSException *exception) 
	{
		[testServerProgressIndicator stopAnimation:self];
		NSRunAlertPanel(@"Connection failure", @"Could not connect to server. Error was: %@", @"Cancel", nil, nil, [exception reason]);
	}
}

- (IBAction)closeAddProjectsSheet:(id)sender
{
	[NSApp endSheet:addProjectsSheet returnCode:[sender tag]];
}

- (void)addProjectsSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
{
	[addProjectsSheet orderOut:self];
	if(returnCode == 0)
		return;
	
	NSLog(@"projects = %@", [chooseProjectsViewController selectedObjects]);
	NSMutableArray *projectIdList = [NSMutableArray array];
	NSEnumerator *projectInfoEnum = [[chooseProjectsViewController selectedObjects] objectEnumerator];
	NSDictionary *projectInfo;
	while((projectInfo = [projectInfoEnum nextObject]) != nil)
	{
		[projectIdList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			[projectInfo objectForKey:@"name"], @"name", 
			[self getServerURL], @"server", nil]];
	}
	NSData *data = [NSArchiver archivedDataWithRootObject:projectIdList];
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:@"Projects"];

}

@end
