
#import "CCMProjectRepository.h"
#import "CCMProject.h"

NSString *CCMBuildCompleteNotification = @"CCMBuildCompleteNotification";

NSString *CCMSuccessfulBuild = @"Successful";
NSString *CCMFixedBuild = @"Fixed";
NSString *CCMBrokenBuild = @"Broken";
NSString *CCMStillFailingBuild = @"Still failing";


@implementation CCMProjectRepository

- (id)initWithConnection:(CCMConnection *)aConnection andProjects:(NSArray *)projectNames
{
	[super init];
	connection = [aConnection retain];
	projects = [[NSMutableDictionary alloc] init];
	NSEnumerator *nameEnum = [projectNames objectEnumerator];
	NSString *name;
	while((name = [nameEnum nextObject]) != nil)
		[projects setObject:[[[CCMProject alloc] initWithName:name] autorelease] forKey:name];		
	return self;
}

- (void)dealloc
{
	[connection release];
	[projects release];
	[super dealloc];	
}

- (void)setNotificationCenter:(NSNotificationCenter *)center
{
	notificationCenter = center;
}

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

- (void)pollServer
{
	NSEnumerator *infoEnum = [[connection getProjectInfos] objectEnumerator];
	NSDictionary *info;
	while((info = [infoEnum nextObject]) != nil)
	{
		CCMProject *project = [projects objectForKey:[info objectForKey:@"name"]];
		if(project == nil)
			continue;
		
		if([[project valueForKey:@"activity"] isEqualToString:CCMBuildingActivity] &&
		   ![[info objectForKey:@"activity"] isEqualToString:CCMBuildingActivity])
		{
			NSDictionary *buildCompleteInfo = [self buildCompleteInfoForProject:project andNewProjectInfo:info];
			[notificationCenter postNotificationName:CCMBuildCompleteNotification object:self userInfo:buildCompleteInfo];
		} 
		else if(([project valueForKey:@"lastBuildStatus"] != nil) &&
				![[project valueForKey:@"lastBuildStatus"] isEqualToString:[info valueForKey:@"lastBuildStatus"]])
		{
			NSDictionary *buildCompleteInfo = [self buildCompleteInfoForProject:project andNewProjectInfo:info];
			[notificationCenter postNotificationName:CCMBuildCompleteNotification object:self userInfo:buildCompleteInfo];
		}
		[project updateWithInfo:info];
	}
}

- (NSArray *)projects
{
	return [projects allValues];
}

@end
