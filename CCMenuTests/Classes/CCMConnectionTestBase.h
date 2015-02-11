
#import <XCTest/XCTest.h>

@interface CCMConnectionTestBase : XCTestCase

- (NSURLConnection *)setUpDummyNSURLConnection;
- (NSData *)responseData;
- (id)responseMockWithStatusCode:(NSInteger)statusCode;

@end