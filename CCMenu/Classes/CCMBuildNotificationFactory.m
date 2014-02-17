
#import "CCMBuildNotificationFactory.h"
#import "CCMProject.h"
#import "CCMProjectStatus.h"


NSString *CCMBuildStartNotification = @"CCMBuildStartNotification";
NSString *CCMBuildCompleteNotification = @"CCMBuildCompleteNotification";

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

- (NSDictionary *)buildCompleteInfoForProject:(CCMProject *)project withOldStatus:(CCMProjectStatus *)oldStatus
{
	NSMutableDictionary *notificationInfo = [NSMutableDictionary dictionary];
	[notificationInfo setObject:oldStatus forKey:@"oldStatus"];
	NSString *result = [self buildResultForLastStatus:oldStatus newStatus:[project status]];
	[notificationInfo setObject:result forKey:@"buildResult"];
    if([[project status] webUrl] != nil)
        [notificationInfo setObject:[[project status] webUrl] forKey:@"webUrl"];
	return notificationInfo;
}

- (NSDictionary *)buildStartInfoForProject:(CCMProject *)project withOldStatus:(CCMProjectStatus *)oldStatus
{
	NSMutableDictionary *notificationInfo = [NSMutableDictionary dictionary];
	[notificationInfo setObject:oldStatus forKey:@"oldStatus"];
	return notificationInfo;
}

- (NSNotification *)notificationForProject:(CCMProject *)project withOldStatus:(CCMProjectStatus *)oldStatus
{
	if(![oldStatus isBuilding] && [[project status] isBuilding])
    {
		NSDictionary *buildStartInfo = [self buildStartInfoForProject:project withOldStatus:oldStatus];
		return [NSNotification notificationWithName:CCMBuildStartNotification object:project userInfo:buildStartInfo];
    }
	if([oldStatus isBuilding] && ![[project status] isBuilding])
	{
		NSDictionary *buildCompleteInfo = [self buildCompleteInfoForProject:project withOldStatus:oldStatus];
		return [NSNotification notificationWithName:CCMBuildCompleteNotification object:project userInfo:buildCompleteInfo];
	} 
	if(([oldStatus lastBuildStatus] != nil) &&
       ![[oldStatus lastBuildStatus] isEqualToString:[[project status] lastBuildStatus]])
	{
		NSDictionary *buildCompleteInfo = [self buildCompleteInfoForProject:project withOldStatus:oldStatus];
		return [NSNotification notificationWithName:CCMBuildCompleteNotification object:project userInfo:buildCompleteInfo];
	}
    if([oldStatus isBuilding] && [[project status] isBuilding] &&
       [oldStatus lastBuildLabel] != nil && ![[oldStatus lastBuildLabel] isEqualToString:[[project status] lastBuildLabel]])
    {
		NSDictionary *buildStartInfo = [self buildStartInfoForProject:project withOldStatus:oldStatus];
		return [NSNotification notificationWithName:CCMBuildStartNotification object:project userInfo:buildStartInfo];
    }
       
	return nil;
}

@end
