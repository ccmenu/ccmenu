
#import "CCMMenuButton.h"


@implementation CCMMenuButton

- (void)mouseDown:(NSEvent *)theEvent
{
    if([self isEnabled])
        [NSMenu popUpContextMenu:popUpMenu withEvent:theEvent forView:self];
}

@end
