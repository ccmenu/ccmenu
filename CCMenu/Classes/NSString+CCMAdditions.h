
#import <Cocoa/Cocoa.h>

typedef enum {
	CCMUnknownServer = -1,
	CCMCruiseControlDashboard = 0,
	CCMCruiseControlClassic = 1,
 	CCMCruiseControlDotNetServer = 2,   // CC.rb uses the same URL
	CCMHudsonServer = 3
} CCMServerType;


@interface NSString(CCMAdditions)

- (CCMServerType)serverType;
- (NSString *)completeURLForServerType:(CCMServerType)serverType;
- (NSArray *)completeURLForAllServerTypes;
- (NSString *)stringByRemovingServerReportFileName;

@end
