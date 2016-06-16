
#import "CCMBuildNotificationFactory.h"
#import "CCMProject.h"
#import "CCMProjectStatus.h"


NSString *CCMBuildStartNotification = @"CCMBuildStartNotification";
NSString *CCMBuildCompleteNotification = @"CCMBuildCompleteNotification";

// Do not change these constants, defaults and NIB depend on them
NSString *CCMSuccessfulBuild = @"Successful";
NSString *CCMFixedBuild = @"Fixed";
NSString *CCMBrokenBuild = @"Broken";
NSString *CCMStillFailingBuild = @"StillFailing";


@implementation CCMBuildNotificationFactory

- (NSString *)buildResultForLastStatus:(CCMProjectStatus *)lastStatus newStatus:(CCMProjectStatus *)newStatus
{
	if(![lastStatus buildDidFail] && [newStatus buildWasSuccessful])
		return CCMSuccessfulBuild;
	if([lastStatus buildWasSuccessful] && [newStatus buildDidFail])
		return CCMBrokenBuild;
	if([lastStatus buildDidFail] && [newStatus buildWasSuccessful])
		return CCMFixedBuild;
	if(![lastStatus buildWasSuccessful] && [newStatus buildDidFail])
		return CCMStillFailingBuild;
	return @"";
}

- (NSNotification *)buildCompleteNotificationForProject:(CCMProject *)project withOldStatus:(CCMProjectStatus *)oldStatus
{
	NSMutableDictionary *notificationInfo = [NSMutableDictionary dictionary];
	NSString *result = [self buildResultForLastStatus:oldStatus newStatus:[project status]];
	[notificationInfo setObject:result forKey:@"buildResult"];
    if([[project status] webUrl] != nil)
        [notificationInfo setObject:[[project status] webUrl] forKey:@"webUrl"];
    return [NSNotification notificationWithName:CCMBuildCompleteNotification object:project userInfo:notificationInfo];
}

- (NSNotification *)buildStartNotificationForProject:(CCMProject *)project withOldStatus:(CCMProjectStatus *)oldStatus
{
    NSMutableDictionary *notificationInfo = [NSMutableDictionary dictionary];
    if([[project status] webUrl] != nil)
        [notificationInfo setObject:[[project status] webUrl] forKey:@"webUrl"];
    return [NSNotification notificationWithName:CCMBuildStartNotification object:project userInfo:notificationInfo];
}

- (NSNotification *)notificationForProject:(CCMProject *)project withOldStatus:(CCMProjectStatus *)oldStatus
{
	if(![oldStatus isBuilding] && [[project status] isBuilding])
    {
		return [self buildStartNotificationForProject:project withOldStatus:oldStatus];
    }
	if([oldStatus isBuilding] && ![[project status] isBuilding])
	{
		return [self buildCompleteNotificationForProject:project withOldStatus:oldStatus];
	}
	if(([oldStatus lastBuildStatus] != nil) &&
       ![[oldStatus lastBuildStatus] isEqualToString:[[project status] lastBuildStatus]])
	{
		return [self buildCompleteNotificationForProject:project withOldStatus:oldStatus];
	}
    if([oldStatus isBuilding] && [[project status] isBuilding] &&
       [oldStatus lastBuildLabel] != nil && ![[oldStatus lastBuildLabel] isEqualToString:[[project status] lastBuildLabel]])
    {
		return [self buildStartNotificationForProject:project withOldStatus:oldStatus];
    }
       
	return nil;
}

@end
