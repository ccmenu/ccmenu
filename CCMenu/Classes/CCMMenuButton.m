
#import "CCMMenuButton.h"


@implementation CCMMenuButton

- (void)mouseDown:(NSEvent *)theEvent
{
    [NSMenu popUpContextMenu:popUpMenu withEvent:theEvent forView:self];
}

@end
