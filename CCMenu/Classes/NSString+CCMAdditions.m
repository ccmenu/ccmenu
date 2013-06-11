
#import "NSString+CCMAdditions.h"


@implementation NSString(CCMAdditions)

static NSArray *filenames = nil; 

// we can't use +initialize in categories...
static void initialize()
{
	if(filenames != nil)
		return;
	NSString *plist = @"( 'cctray.xml', 'xml', 'XmlStatusReport.aspx', 'cc.xml' )";
	filenames = [[plist propertyList] copy];
}

- (CCMServerType)serverType
{
	initialize();
    NSString *filename = [self lastPathComponent];
    NSRange qmarkRange = [filename rangeOfString:@"?"];
    if(qmarkRange.location != NSNotFound)
        filename = [filename substringToIndex:qmarkRange.location];
    NSUInteger index = [filenames indexOfObject:filename];
	return (index == NSNotFound) ? CCMUnknownServer : (int)index;
}

- (NSString *)stringByAddingSchemeIfNecessary
{
	if(![self hasPrefix:@"http://"] && ![self hasPrefix:@"https://"])
		return [@"http://" stringByAppendingString:self];
	return self;
}

- (NSString *)completeURLForServerType:(CCMServerType)serverType withPath:(NSString *)path
{
	initialize();
    NSString *baseURL = [self stringByAddingSchemeIfNecessary];

    NSString *queryParams = nil;
    NSRange qmarkRange = [self rangeOfString:@"?"];
    if(qmarkRange.location != NSNotFound)
    {
        baseURL = [baseURL substringToIndex:qmarkRange.location];
        queryParams = [self substringFromIndex:NSMaxRange(qmarkRange)];
    }

    NSString *completion = [path stringByAppendingPathComponent:[filenames objectAtIndex:serverType]];
    NSString *result = baseURL;
	if(![result hasSuffix:completion])
	{
        // not using appendPathComponent: because that normalises the double-slashes in http://
		if(![result hasSuffix:@"/"] && ![completion hasPrefix:@"/"])
            result = [result stringByAppendingString:@"/"];
        result = [result stringByAppendingString:completion];
	}

    if(queryParams != nil)
    {
        result = [result stringByAppendingFormat:@"?%@", queryParams];
    }

	return result;
}

- (NSString *)completeURLForServerType:(CCMServerType)serverType
{
	return [self completeURLForServerType:serverType withPath:@""];
}

- (NSArray *)completeURLForAllServerTypes
{
	if([self serverType] != CCMUnknownServer)
		return [NSArray arrayWithObject:[self stringByAddingSchemeIfNecessary]];
	NSMutableSet *urls = [NSMutableSet set];
	[urls addObject:[self completeURLForServerType:CCMCruiseControlDashboard]];
	[urls addObject:[self completeURLForServerType:CCMCruiseControlDashboard withPath:@"dashboard"]];
	[urls addObject:[self completeURLForServerType:CCMCruiseControlDashboard withPath:@"go"]];
	[urls addObject:[self completeURLForServerType:CCMCruiseControlClassic]];
	[urls addObject:[self completeURLForServerType:CCMCruiseControlDotNetServer]];
	[urls addObject:[self completeURLForServerType:CCMCruiseControlDotNetServer withPath:@"ccnet"]];
	[urls addObject:[self completeURLForServerType:CCMHudsonServer]];
	[urls addObject:[self completeURLForServerType:CCMHudsonServer withPath:@"hudson"]];
	return [urls allObjects];
}

- (NSString *)stringByRemovingServerReportFileName
{
	initialize();
	NSUInteger index = [filenames indexOfObject:[self lastPathComponent]];
	if(index == NSNotFound)
		return self;
	// can't use deleteLastPathComponent because that normalises the double-slash in http://
	NSMutableString *mutableCopy = [[self mutableCopy] autorelease];
	NSRange range = [mutableCopy rangeOfString:[filenames objectAtIndex:index] options:NSBackwardsSearch|NSAnchoredSearch];
	[mutableCopy deleteCharactersInRange:range];
	return [NSString stringWithString:mutableCopy];
}

- (NSString *)usernameFromURL
{
    @try
    {
        return [[NSURL URLWithString:self] user];
    }
    @catch (NSException *exception)
    {
        return nil;
    }
}

@end
