
#import <Cocoa/Cocoa.h>


@interface CCMBuildTimer : NSObject 
{
    
}

- (void)start;

- (void)buildStart:(NSNotification *)notification;
- (void)buildComplete:(NSNotification *)notification;

@end
