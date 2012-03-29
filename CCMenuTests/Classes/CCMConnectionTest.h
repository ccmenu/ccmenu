
#import <SenTestingKit/SenTestingKit.h>
#import "CCMConnection.h"


@interface CCMConnectionTest : SenTestCase 
{
    CCMConnection   *connection;
    id              connectionMock;
    NSArray         *recordedInfos;
    NSString        *recordedError;
}

@end
