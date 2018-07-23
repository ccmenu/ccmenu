
#import <Cocoa/Cocoa.h>

@interface CCMLoginItemsManager : NSObject

- (void)setInLoginItemsList:(BOOL)flag;
- (BOOL)isInLoginItemsList;

- (void)addToLoginItemsList;
- (void)removeFromLoginItemsList;

@end
