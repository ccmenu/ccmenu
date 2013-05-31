
#import <SenTestingKit/SenTestingKit.h>
#import "CCMConnection.h"


@interface CCMConnectionTest : SenTestCase 
{
    CCMConnection   *connection;
    id              connectionMock;
    NSArray         *recordedInfoList;
    NSString        *recordedError;
}

@end
