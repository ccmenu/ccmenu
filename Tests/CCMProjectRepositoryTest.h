
#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import "CCMProjectRepository.h"


@interface CCMProjectRepositoryTest : SenTestCase 
{
	CCMProjectRepository *repository;
	OCMockObject *connectionMock;	

	NSMutableArray *postedNotifications;
}

@end
