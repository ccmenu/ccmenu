
#import "NSString+CCMAdditions.h"


@implementation NSString(CCMAddtions)

static NSArray *filenames = nil; 

// we can't use +initialize in categories...
static void initialize()
{
	if(filenames != nil)
		return;
	NSString *plist = @"( 'cctray.xml', 'xml', 'XmlStatusReport.aspx' )";
	filenames = [[plist propertyList] copy];
}

- (CCMServerType)cruiseControlServerType
{
	initialize();
	unsigned index = [filenames indexOfObject:[self lastPathComponent]];
	return (index == NSNotFound) ? CCMUnknownServer : index;
}

- (NSArray *)completeCruiseControlURLs
{
	return nil;
}

- (NSString *)completeCruiseControlURLForServerType:(CCMServerType)serverType
{
	initialize();
	NSString *result = self;
	if(![result hasPrefix:@"http://"])
	{
		result = [@"http://" stringByAppendingString:result];
	}
	if(![result hasSuffix:[filenames objectAtIndex:serverType]])
	{
		if(![result hasSuffix:@"/"])
			result = [result stringByAppendingString:@"/"];
		result = [result stringByAppendingString:[filenames objectAtIndex:serverType]];
	}
	return result;
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
