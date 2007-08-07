
#import "CCMImageFactory.h"
#import "CCMBuildStatusTransformer.h"

NSString *CCMBuildStatusTransformerName = @"CCMBuildStatusTransformer";


@implementation CCMBuildStatusTransformer

+ (Class)transformedValueClass 
{ 
	return [NSImage class]; 
}

+ (BOOL)allowsReverseTransformation 
{ 
	return NO; 
}

- (void)dealloc
{
	[imageFactory release];
	[super dealloc];
}

- (void)setImageFactory:(CCMImageFactory *)anImageFactory
{
	[imageFactory autorelease];
	imageFactory = [anImageFactory retain];
}

- (id)transformedValue:(id)value 
{
	if(value == nil)
		return nil;
	return [imageFactory imageForActivity:nil lastBuildStatus:value];
}

@end
