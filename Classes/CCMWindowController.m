
#import "CCMWindowController.h"


@implementation CCMWindowController

- (void)dealloc
{
	[toolbarDefinition release];
	[super dealloc];
}

- (NSToolbar *)createToolbarWithName:(NSString *)name
{
	NSString *toolbarResourcePath = [[NSBundle mainBundle] pathForResource:name ofType:@"toolbar"];
	toolbarDefinition = [[NSDictionary dictionaryWithContentsOfFile:toolbarResourcePath] retain];
	NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier:[NSString stringWithFormat:@"%@ Toollbar", name]] autorelease];
	[toolbar setDelegate:self];
	return toolbar;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return [toolbarDefinition objectForKey:@"defaultItemIdentifiers"];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar 
{
	return [toolbarDefinition objectForKey:@"allowedItemIdentifiers"];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	return [toolbarDefinition objectForKey:@"selectableItemIdentifiers"];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)identifier willBeInsertedIntoToolbar:(BOOL)willBeInserted 
{
	NSDictionary *itemDef = [[toolbarDefinition objectForKey:@"itemInfoByIdentifier"] objectForKey:identifier];
	NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:identifier] autorelease];
	[item setTarget:self];
	[item setAction:NSSelectorFromString([itemDef objectForKey:@"action"])];
	[item setImage:[NSImage imageNamed:[itemDef objectForKey:@"imageName"]]];
	[item setLabel:[itemDef objectForKey:@"label"]];        
	[item setToolTip:[itemDef objectForKey:@"toolTop"]];
	return item;
}

@end
