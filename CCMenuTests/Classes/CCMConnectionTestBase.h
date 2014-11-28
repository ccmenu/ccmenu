
#import <XCTest/XCTest.h>

@interface CCMConnectionTestBase : XCTestCase
{
    NSURLConnection *dummyNSURLConnection;
}

- (void)setUpDummyNSURLConnection;
- (NSData *)responseData;
- (id)responseMockWithStatusCode:(NSInteger)statusCode;

@end