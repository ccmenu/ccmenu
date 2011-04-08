
#import "CCMStatusItemApplication.h"

static NSDictionary *bindings;


@implementation CCMStatusItemApplication

+ (void)initialize
{
	NSString *plist = @"{ x = cut:; c = copy:; v = paste:; a = selectAll:; m = performMiniaturize:; w = performClose:; }";
	bindings = [[plist propertyList] copy];
}

- (void)sendEvent:(NSEvent *)event
{
	if(([event type] == NSKeyDown) && (![event isARepeat]) && ([event modifierFlags] & NSCommandKeyMask))
	{
		NSString *action = [bindings objectForKey:[event characters]];
		if(action != nil)
			[[[self keyWindow] firstResponder] doCommandBySelector:NSSelectorFromString(action)];
		return;
	}
	[super sendEvent:event];
}

@end