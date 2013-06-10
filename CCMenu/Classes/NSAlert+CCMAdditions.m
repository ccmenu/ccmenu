
#import "NSAlert+CCMAdditions.h"


@implementation NSAlert(CCMAdditions)

+ (NSAlert *)alertWithText:(NSString *)messageText informativeText:(NSString *)informativeText
{
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:messageText];
    [alert setInformativeText:informativeText];
    return alert;
}

@end