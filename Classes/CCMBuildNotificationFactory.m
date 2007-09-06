
#import "CCMBuildNotificationFactory.h"

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

- (NSDictionary *)buildCompleteInfoForProject:(CCMProject *)project andNewProjectInfo:(NSDictionary *)projectInfo
{
	NSMutableDictionary *notificationInfo = [NSMutableDictionary dictionary];
	[notificationInfo setObject:[project valueForKey:@"name"] forKey:@"projectName"];
	NSString *lastStatus = [project valueForKey:@"lastBuildStatus"];
	NSString *newStatus = [projectInfo objectForKey:@"lastBuildStatus"];
	NSString *result = [self buildResultForLastStatus:lastStatus newStatus:newStatus];
	[notificationInfo setObject:result forKey:@"buildResult"];
	return notificationInfo;
}

- (NSNotification *)buildCompleteNotificationForProject:(CCMProject *)project andNewInfo:(NSDictionary *)info
{
	if([[project valueForKey:@"activity"] isEqualToString:CCMBuildingActivity] &&
	   ![[info objectForKey:@"activity"] isEqualToString:CCMBuildingActivity])
	{
		NSDictionary *buildCompleteInfo = [self buildCompleteInfoForProject:project andNewProjectInfo:info];
		return [NSNotification notificationWithName:CCMBuildCompleteNotification object:nil userInfo:buildCompleteInfo];
	} 
	else if(([project valueForKey:@"lastBuildStatus"] != nil) &&
			![[project valueForKey:@"lastBuildStatus"] isEqualToString:[info valueForKey:@"lastBuildStatus"]])
	{
		NSDictionary *buildCompleteInfo = [self buildCompleteInfoForProject:project andNewProjectInfo:info];
		return [NSNotification notificationWithName:CCMBuildCompleteNotification object:nil userInfo:buildCompleteInfo];
	}
	return nil;
}

@end
