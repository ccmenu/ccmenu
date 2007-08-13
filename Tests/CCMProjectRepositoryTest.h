
#import <SenTestingKit/SenTestingKit.h>
#import "CCMProjectRepository.h"


@interface CCMProjectRepositoryTest : SenTestCase 
{
	CCMProjectRepository *repository;
	NSMutableDictionary *projectInfo;
	NSMutableArray *postedNotifications;
}

@end
