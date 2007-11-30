
#import <Cocoa/Cocoa.h>

typedef enum {
	CCMUnknownServer = -1,
	CCMCruiseControlDashboard = 0,
	CCMCruiseControlClassic = 1,
 	CCMCruiseControlDotNetServer = 2   // CC.rb uses the same URL
} CCMServerType;


@interface NSString(CCMAdditions)

- (CCMServerType)cruiseControlServerType;
- (NSArray *)completeCruiseControlURLs;
- (NSString *)completeCruiseControlURLForServerType:(CCMServerType)serverType;
- (NSString *)stringByRemovingCruiseControlReportFileName;

@end
