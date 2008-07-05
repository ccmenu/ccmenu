
#import <Cocoa/Cocoa.h>

typedef enum {
	CCMUnknownServer = -1,
	CCMCruiseControlDashboard = 0,
	CCMCruiseControlClassic = 1,
 	CCMCruiseControlDotNetServer = 2,   // CC.rb uses the same URL
	CCMHudsonServer = 3
} CCMServerType;


@interface NSString(CCMAdditions)

- (CCMServerType)cruiseControlServerType;
- (NSString *)completeCruiseControlURLForServerType:(CCMServerType)serverType;
- (NSArray *)completeCruiseControlURLs;
- (NSString *)stringByRemovingCruiseControlReportFileName;

@end
