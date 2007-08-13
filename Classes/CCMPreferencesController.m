
#import "CCMPreferencesController.h"
#import "CCMConnection.h"

NSString *CCMDefaultsProjectListKey = @"Projects";
NSString *CCMDefaultsProjectEntryNameKey = @"projectName";
NSString *CCMDefaultsProjectEntryServerUrlKey = @"serverUrl";


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

- (void)addProjects:(id)sender
{
	[sheetTabView selectFirstTabViewItem:self];
	[NSApp beginSheet:addProjectsSheet modalForWindow:preferencesWindow modalDelegate:self 
		didEndSelector:@selector(addProjectsSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)chooseProjects:(id)sender
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

- (void)closeAddProjectsSheet:(id)sender
{
	[NSApp endSheet:addProjectsSheet returnCode:[sender tag]];
}

- (void)addProjectsSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
{
	[addProjectsSheet orderOut:self];
	if(returnCode == 0)
		return;
	
	NSMutableArray *defaultsProjectList = [NSMutableArray array];
	NSEnumerator *projectInfoEnum = [[chooseProjectsViewController selectedObjects] objectEnumerator];
	NSDictionary *projectInfo;
	while((projectInfo = [projectInfoEnum nextObject]) != nil)
	{
		[defaultsProjectList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			[projectInfo objectForKey:@"name"], CCMDefaultsProjectEntryNameKey, 
			[[self getServerURL] absoluteString], CCMDefaultsProjectEntryServerUrlKey, nil]];
	}
	NSData *data = [NSArchiver archivedDataWithRootObject:defaultsProjectList];
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:CCMDefaultsProjectListKey];

}

@end
