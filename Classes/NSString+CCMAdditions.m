
#import "NSString+CCMAdditions.h"


@implementation NSString(CCMAddtions)

static NSArray *filenames = nil; 

// we can't use +initialize in categories...
static void initialize()
{
	if(filenames != nil)
		return;
	NSString *plist = @"( 'cctray.xml', 'xml', 'XmlStatusReport.aspx', 'cc.xml' )";
	filenames = [[plist propertyList] copy];
}

- (CCMServerType)cruiseControlServerType
{
	initialize();
	unsigned index = [filenames indexOfObject:[self lastPathComponent]];
	return (index == NSNotFound) ? CCMUnknownServer : index;
}

- (NSString *)stringByAddingSchemeIfNecessary
{
	if(![self hasPrefix:@"http://"] && ![self hasPrefix:@"https://"])
		return [@"http://" stringByAppendingString:self];
	return self;
}

- (NSString *)completeCruiseControlURLForServerType:(CCMServerType)serverType withPath:(NSString *)path
{
	initialize();
	NSString *completion = [path stringByAppendingPathComponent:[filenames objectAtIndex:serverType]];
	NSString *result = self;
	if(![result hasSuffix:completion])
	{
		// can't use appendPathComponent because that normalises the double-slash in http://
		if(![result hasSuffix:@"/"])
			result = [result stringByAppendingString:@"/"];
		result = [result stringByAppendingString:completion];
	}
	return [result stringByAddingSchemeIfNecessary];
}

- (NSString *)completeCruiseControlURLForServerType:(CCMServerType)serverType
{
	return [self completeCruiseControlURLForServerType:serverType withPath:@""];
}

- (NSArray *)completeCruiseControlURLs
{
	if([self cruiseControlServerType] != CCMUnknownServer)
		return [NSArray arrayWithObject:[self stringByAddingSchemeIfNecessary]];
	NSMutableSet *urls = [NSMutableSet set];
	[urls addObject:[self completeCruiseControlURLForServerType:CCMCruiseControlDashboard]];
	[urls addObject:[self completeCruiseControlURLForServerType:CCMCruiseControlDashboard withPath:@"dashboard"]];
	[urls addObject:[self completeCruiseControlURLForServerType:CCMCruiseControlClassic]];
	[urls addObject:[self completeCruiseControlURLForServerType:CCMCruiseControlDotNetServer]];
	[urls addObject:[self completeCruiseControlURLForServerType:CCMCruiseControlDotNetServer withPath:@"ccnet"]];
	[urls addObject:[self completeCruiseControlURLForServerType:CCMHudsonServer]];
	[urls addObject:[self completeCruiseControlURLForServerType:CCMHudsonServer withPath:@"hudson"]];
	return [urls allObjects];
}

- (NSString *)stringByRemovingCruiseControlReportFileName
{
	initialize();
	unsigned index = [filenames indexOfObject:[self lastPathComponent]];
	if(index == NSNotFound)
		return self;
	// can't use deleteLastPathComponent because that normalises the double-slash in http://
	NSMutableString *mutableCopy = [self mutableCopy];
	NSRange range = [mutableCopy rangeOfString:[filenames objectAtIndex:index] options:NSBackwardsSearch|NSAnchoredSearch];
	[mutableCopy deleteCharactersInRange:range];
	return [NSString stringWithString:mutableCopy];
}

@end
