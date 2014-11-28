
#import <XCTest/XCTest.h>
#import "CCMBuildNotificationFactory.h"
#import "CCMProjectBuilder.h"


@interface CCMBuildNotificationFactoryTest : XCTestCase
{
	CCMBuildNotificationFactory	*factory;
    CCMProjectBuilder *builder;
}

@end


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
	
	XCTAssertNotNil(notification, @"Should have created a notification.");
	XCTAssertEqualObjects(CCMBuildCompleteNotification, [notification name], @"Should have created correct notification.");
    XCTAssertEqual(project, [notification object], @"Should have set correct notification object.");
	NSDictionary *userInfo = [notification userInfo];
	XCTAssertEqualObjects(CCMSuccessfulBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testCreatesBrokenBuildCompleteNotification
{	
	CCMProjectStatus *old = [[[builder status] withActivity:@"Building"] withBuildStatus:@"Success"];
    CCMProject *project = [[[builder project] withActivity:@"Sleeping"] withBuildStatus:@"Failure"];

	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];

	NSDictionary *userInfo = [notification userInfo];
	XCTAssertEqualObjects(CCMBrokenBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testCreatesFixedBuildCompleteNotification
{	
    CCMProjectStatus *old = [[[builder status] withActivity:@"Building"] withBuildStatus:@"Failure"];
    CCMProject *project = [[[builder project] withActivity:@"Sleeping"] withBuildStatus:@"Success"];

	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];

	NSDictionary *userInfo = [notification userInfo];
	XCTAssertEqualObjects(CCMFixedBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testCreatesStillFailingBuildCompleteNotification
{	
    CCMProjectStatus *old = [[[builder status] withActivity:@"Building"] withBuildStatus:@"Failure"];
    CCMProject *project = [[[builder project] withActivity:@"Sleeping"] withBuildStatus:@"Failure"];

	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];
	
	NSDictionary *userInfo = [notification userInfo];
	XCTAssertEqualObjects(CCMStillFailingBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");
}

- (void)testCreatesBrokenBuildCompletionNotificationEvenIfBuildWasMissed
{
    CCMProjectStatus *old = [[[builder status] withActivity:@"Sleeping"] withBuildStatus:@"Success"];
    CCMProject *project = [[[builder project] withActivity:@"Sleeping"] withBuildStatus:@"Failure"];

	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];
	
	NSDictionary *userInfo = [notification userInfo];
	XCTAssertEqualObjects(CCMBrokenBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");	
}

- (void)testCreatesFixedBuildCompletionNotificationEvenIfBuildWasMissed
{
    CCMProjectStatus *old = [[[builder status] withActivity:@"Sleeping"] withBuildStatus:@"Failure"];
    CCMProject *project = [[[builder project] withActivity:@"Sleeping"] withBuildStatus:@"Success"];

	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];
	
	NSDictionary *userInfo = [notification userInfo];
	XCTAssertEqualObjects(CCMFixedBuild, [userInfo objectForKey:@"buildResult"], @"Should have set correct build result.");	
}

- (void)testCreatesBuildStartingNotification
{
    CCMProjectStatus *old = [[[builder status] withActivity:@"Sleeping"] withBuildStatus:@"Success"];
    CCMProject *project = [[[builder project] withActivity:@"Building"] withBuildStatus:@"Failure"];

	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];

	XCTAssertNotNil(notification, @"Should have created a notification.");
	XCTAssertEqualObjects(CCMBuildStartNotification, [notification name], @"Should have created correct notification.");
    XCTAssertEqual(project, [notification object], @"Should have set correct notification object.");
}

- (void)testCreatesBuildStartingNotificationOnMissedSleeping
{
	CCMProjectStatus *old = [[[[builder status] withActivity:@"Building"] withBuildStatus:@"Success"] withBuildLabel:@"build.1"];
    CCMProject *project = [[[[builder project] withActivity:@"Building"] withBuildStatus:@"Success"] withBuildLabel:@"build.2"];
     
	NSNotification *notification = [factory notificationForProject:project withOldStatus:old];
    
	XCTAssertNotNil(notification, @"Should have created a notification.");
	XCTAssertEqualObjects(CCMBuildStartNotification, [notification name], @"Should have created correct notification.");
    XCTAssertEqual(project, [notification object], @"Should have set correct notification object.");
}

@end
