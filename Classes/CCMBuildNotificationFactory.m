
#import "CCMBuildNotificationFactory.h"
#import "CCMProject.h"


NSString *CCMBuildCompleteNotification = @"CCMBuildCompleteNotification";

NSString *CCMSuccessfulBuild = @"Successful";
NSString *CCMFixedBuild = @"Fixed";
NSString *CCMBrokenBuild = @"Broken";
NSString *CCMStillFailingBuild = @"Still failing";


@implementation CCMBuildNotificationFactory

- (NSString *)buildResultForLastStatus:(NSString *)lastStatus newStatus:(NSString *)newStatus
{
	if([lastStatus isEqualToString:CCMSuccessStatus] && [newStatus isEqualToString:CCMSuccessStatus])
		return CCMSuccessfulBuild;
	if([lastStatus isEqualToString:CCMSuccessStatus] && [newStatus isEqualToString:CCMFailedStatus])
		return CCMBrokenBuild;
	if([lastStatus isEqualToString:CCMFailedStatus] && [newStatus isEqualToString:CCMSuccessStatus])
		return CCMFixedBuild;
	if([lastStatus isEqualToString:CCMFailedStatus] && [newStatus isEqualToString:CCMFailedStatus])
		return CCMStillFailingBuild;
	return @"";
}

- (NSDictionary *)notificationInfoForOldProjectInfo:(NSDictionary *)oldInfo andNewInfo:(NSDictionary *)newInfo
{
	NSMutableDictionary *notificationInfo = [NSMutableDictionary dictionary];
	[notificationInfo setObject:[oldInfo objectForKey:@"name"] forKey:@"projectName"];
	NSString *lastStatus = [oldInfo objectForKey:@"lastBuildStatus"];
	NSString *newStatus = [newInfo objectForKey:@"lastBuildStatus"];
	NSString *result = [self buildResultForLastStatus:lastStatus newStatus:newStatus];
	[notificationInfo setObject:result forKey:@"buildResult"];
	return notificationInfo;
}

- (NSNotification *)buildCompleteNotificationForOldProjectInfo:(NSDictionary *)oldInfo andNewProjectInfo:(NSDictionary *)newInfo
{
	if([[oldInfo objectForKey:@"activity"] isEqualToString:CCMBuildingActivity] &&
	   ![[newInfo objectForKey:@"activity"] isEqualToString:CCMBuildingActivity])
	{
		NSDictionary *buildCompleteInfo = [self notificationInfoForOldProjectInfo:oldInfo andNewInfo:newInfo];
		return [NSNotification notificationWithName:CCMBuildCompleteNotification object:nil userInfo:buildCompleteInfo];
	} 
	else if(([oldInfo objectForKey:@"lastBuildStatus"] != nil) &&
			![[oldInfo objectForKey:@"lastBuildStatus"] isEqualToString:[newInfo objectForKey:@"lastBuildStatus"]])
	{
		NSDictionary *buildCompleteInfo = [self notificationInfoForOldProjectInfo:oldInfo andNewInfo:newInfo];
		return [NSNotification notificationWithName:CCMBuildCompleteNotification object:nil userInfo:buildCompleteInfo];
	}
	return nil;
}

@end
