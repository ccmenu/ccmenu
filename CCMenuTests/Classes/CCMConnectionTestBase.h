
#import <SenTestingKit/SenTestingKit.h>

@interface CCMConnectionTestBase : SenTestCase
{
    NSURLConnection *dummyNSURLConnection;
}

- (void)setUpDummyNSURLConnection;
- (NSData *)responseData;
- (id)responseMockWithStatusCode:(NSInteger)statusCode;

@end