
#import <Cocoa/Cocoa.h>

typedef enum {
	CCMUnknownServer = -1,
	CCMCruiseControlDashboard = 0,
	CCMCruiseControlClassic = 1,
 	CCMCruiseControlDotNetServer = 2,   // CC.rb uses the same URL
	CCMHudsonServer = 3 // Jenkins, Travis use same URL
} CCMServerType;

typedef enum {
    CCMDetectServer = -1,
    CCMUseGivenURL = 0
} CCMServerURLHandling;


@interface NSString(CCMAdditions)

- (CCMServerType)serverType;
- (NSString *)stringByAddingSchemeIfNecessary;
- (NSString *)completeURLForServerType:(CCMServerType)serverType;
- (NSArray *)completeURLForAllServerTypes;
- (NSString *)stringByRemovingServerReportFileName;
- (NSString *)usernameFromURL;

@end
