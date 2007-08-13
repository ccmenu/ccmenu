
#import "CCMPreferencesController.h"
#import "CCMConnection.h"


@implementation CCMPreferencesController

- (NSURL *)getServerURL
{
	NSArray *allFilenames = [NSArray arrayWithObjects:@"cctray.xml", @"xml.jsp", @"XmlServerReport.aspx", @"??", @"", nil];
	NSString *filename = [allFilenames objectAtIndex:[[serverTypeMatrix selectedCell] tag]];
	NSString *serverUrl = [serverUrlComboBox stringValue];
	if(([serverUrl length] > 0) && (![serverUrl hasSuffix:filename]))
	{
		if(![serverUrl hasSuffix:@"/"])
			serverUrl = [serverUrl stringByAppendingString:@"/"];
		serverUrl = [serverUrl stringByAppendingString:filename];
	}
	return [NSURL URLWithString:serverUrl];
}

- (NSArray *)getProjectInfosFromURL:(NSURL *)url
{
	@try 
	{
		CCMConnection *connection = [[[CCMConnection alloc] initWithURL:url] autorelease];
		NSArray *projectInfos = [connection getProjectInfos];
		return projectInfos;
	}
	@catch (NSException *exception) 
	{
		[testServerProgressIndicator stopAnimation:self]; // just in case...
		NSRunAlertPanel(@"Connection failure", @"Could not connect to server. Error was: %@", @"Cancel", nil, nil, [exception reason]);
	}
	return nil;
}

- (void)showWindow:(id)sender
{
	if(preferencesWindow == nil)
	{
		[NSBundle loadNibNamed:@"Preferences" owner:self];
	}
	[preferencesWindow makeKeyAndOrderFront:self];	
}

- (IBAction)addServer:(id)sender
{
	[NSApp beginSheet:addServerSheet modalForWindow:preferencesWindow modalDelegate:self 
		didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)testServerConnection:(id)sender
{
	[testServerProgressIndicator startAnimation:self];
	NSArray *projectInfos = [self getProjectInfosFromURL:[self getServerURL]];
	[testServerProgressIndicator stopAnimation:self];
	if([projectInfos count] > 0)
		NSRunAlertPanel(@"Successful", @"Connected to server and found %u projects.", @"OK" , nil, nil, [projectInfos count]);
	else if(projectInfos != nil)
		NSRunAlertPanel(@"Successful", @"Connected to server but found no projects. Did you select the correct server type?" ,@"OK" , nil, nil);
}

- (IBAction)closeAddServerSheet:(id)sender
{
	[NSApp endSheet:addServerSheet returnCode:[[sender selectedCell] tag]];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
{
	[addServerSheet orderOut:self];
	if(returnCode == 0)
		return;
	
	NSURL *serverUrl = [self getServerURL];
	NSArray *projectInfos = [self getProjectInfosFromURL:serverUrl];
	NSMutableArray *projectConfigs = [NSMutableArray array];
	NSEnumerator *projectInfoEnum = [projectInfos objectEnumerator];
	NSDictionary *projectInfo;
	while((projectInfo = [projectInfoEnum nextObject]) != nil)
	{
		NSMutableDictionary *configInfo = [NSMutableDictionary dictionary];
		[configInfo setObject:[projectInfo objectForKey:@"name"] forKey:@"name"];
		[configInfo setObject:[NSNumber numberWithBool:TRUE] forKey:@"monitor"];
		[projectConfigs addObject:configInfo];
	}	
	NSMutableDictionary *server = [NSMutableDictionary dictionary];
	[server setObject:[serverUrl standardizedURL] forKey:@"name"];
	[server setObject:projectConfigs forKey:@"projects"];

	NSData *data = [NSArchiver archivedDataWithRootObject:[NSMutableArray arrayWithObject:server]];
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:@"Projects"];

	[serverAndProjectView expandItem:[serverAndProjectView itemAtRow:0] expandChildren:YES];
}

- (void)removeServer:(id)sender
{
}



@end
