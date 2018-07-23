
#import "CCMLoginItemsManager.h"

@implementation CCMLoginItemsManager

- (void)setInLoginItemsList:(BOOL)flag
{
    if(flag)
        [self addToLoginItemsList];
    else
        [self removeFromLoginItemsList];
}


LSSharedFileListItemRef itemForThisAppInList(LSSharedFileListRef list)
{
    CFArrayRef listSnapshotRef = LSSharedFileListCopySnapshot(list, NULL);
    NSURL *bundleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];

    for(id item in (__bridge NSArray *)listSnapshotRef)
    {
        CFURLRef itemURLRef;
        if(LSSharedFileListItemResolve((LSSharedFileListItemRef)item, 0, &itemURLRef, NULL) == noErr)
        {
            if([(__bridge NSURL *)itemURLRef isEqual:bundleURL])
            {
                CFRelease(itemURLRef);
                return (LSSharedFileListItemRef)item;
            }
            CFRelease(itemURLRef);
        }
    }
    return NULL;
}


- (BOOL)isInLoginItemsList
{
    LSSharedFileListRef loginItemsListRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    return itemForThisAppInList(loginItemsListRef) != NULL;
}


- (void)addToLoginItemsList
{
    LSSharedFileListRef loginItemsListRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if(itemForThisAppInList(loginItemsListRef) != NULL)
        return; // already in list, nothing to do
    
    NSURL *bundleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    NSDictionary *properties = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"com.apple.loginitem.HideOnLaunch"];
    LSSharedFileListItemRef itemRef = LSSharedFileListInsertItemURL(loginItemsListRef, kLSSharedFileListItemLast, NULL, NULL, (CFURLRef)bundleURL, (CFDictionaryRef)properties, NULL);
    if(itemRef != NULL)
        CFRelease(itemRef);
}


- (void)removeFromLoginItemsList
{
    LSSharedFileListRef loginItemsListRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    LSSharedFileListItemRef itemRef = itemForThisAppInList(loginItemsListRef);
    
    if(itemRef == NULL)
        return; // not in list, nothing to do

     LSSharedFileListItemRemove(loginItemsListRef, itemRef);
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"Trying to set %@ to %@", key, value);
}

@end
