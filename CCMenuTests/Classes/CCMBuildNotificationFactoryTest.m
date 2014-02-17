
#import "CCMBuildNotificationFactoryTest.h"
#import "CCMProject.h"


@implementation CCMBuildNotificationFactoryTest

- (void)setUp
{
    builder = [[[CCMProjectBuilder alloc] init] autorelease];
	factory = [[[CCMBuildNotificationFactory alloc] init] autorelease];	
}

- (void)testCreatesSuccessfulBuildCompleteNotification
{
	CCMProjectStatus *old = [[[builder status] withActivity:@"Building"] withBuildStatus:@"Success"];
    CCMProject *project = [[[builder project] withActivity:@"Sleeping"] withBuildStatus:@"Success"];

	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];
	
	STAssertNotNil(notification, @"Should have created a notification.");
	STAssertEqualObjects(CCMBuildCompleteNotification, [notification name], @"Should have created correct notification.");
    STAssertEquals(project, [notification object], @"Should have set correct notification object.");
	NSDictionary *userInfo = [notification userInfo];
	STAssertEqualObjects(CCMSuccessfulBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testCreatesBrokenBuildCompleteNotification
{	
	CCMProjectStatus *old = [[[builder status] withActivity:@"Building"] withBuildStatus:@"Success"];
    CCMProject *project = [[[builder project] withActivity:@"Sleeping"] withBuildStatus:@"Failure"];

	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];

	NSDictionary *userInfo = [notification userInfo];
	STAssertEqualObjects(CCMBrokenBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testCreatesFixedBuildCompleteNotification
{	
    CCMProjectStatus *old = [[[builder status] withActivity:@"Building"] withBuildStatus:@"Failure"];
    CCMProject *project = [[[builder project] withActivity:@"Sleeping"] withBuildStatus:@"Success"];

	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];

	NSDictionary *userInfo = [notification userInfo];
	STAssertEqualObjects(CCMFixedBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testCreatesStillFailingBuildCompleteNotification
{	
    CCMProjectStatus *old = [[[builder status] withActivity:@"Building"] withBuildStatus:@"Failure"];
    CCMProject *project = [[[builder project] withActivity:@"Sleeping"] withBuildStatus:@"Failure"];

	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];
	
	NSDictionary *userInfo = [notification userInfo];
	STAssertEqualObjects(CCMStillFailingBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testCreatesBrokenBuildCompletionNotificationEvenIfBuildWasMissed
{
    CCMProjectStatus *old = [[[builder status] withActivity:@"Sleeping"] withBuildStatus:@"Success"];
    CCMProject *project = [[[builder project] withActivity:@"Sleeping"] withBuildStatus:@"Failure"];

	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];
	
	NSDictionary *userInfo = [notification userInfo];
	STAssertEqualObjects(CCMBrokenBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");	
}

- (void)testCreatesFixedBuildCompletionNotificationEvenIfBuildWasMissed
{
    CCMProjectStatus *old = [[[builder status] withActivity:@"Sleeping"] withBuildStatus:@"Failure"];
    CCMProject *project = [[[builder project] withActivity:@"Sleeping"] withBuildStatus:@"Success"];

	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];
	
	NSDictionary *userInfo = [notification userInfo];
	STAssertEqualObjects(CCMFixedBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");	
}

- (void)testCreatesBuildStartingNotification
{
    CCMProjectStatus *old = [[[builder status] withActivity:@"Sleeping"] withBuildStatus:@"Success"];
    CCMProject *project = [[[builder project] withActivity:@"Building"] withBuildStatus:@"Failure"];

	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];

	STAssertNotNil(notification, @"Should have created a notification.");
	STAssertEqualObjects(CCMBuildStartNotification, [notification name], @"Should have created correct notification.");
    STAssertEquals(project, [notification object], @"Should have set correct notification object.");
}

- (void)testCreatesBuildStartingNotificationOnMissedSleeping
{
	CCMProjectStatus *old = [[[[builder status] withActivity:@"Building"] withBuildStatus:@"Success"] withBuildLabel:@"build.1"];
    CCMProject *project = [[[[builder project] withActivity:@"Building"] withBuildStatus:@"Success"] withBuildLabel:@"build.2"];
     
	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];
    
	STAssertNotNil(notification, @"Should have created a notification.");
	STAssertEqualObjects(CCMBuildStartNotification, [notification name], @"Should have created correct notification.");
    STAssertEquals(project, [notification object], @"Should have set correct notification object.");
}

@end
