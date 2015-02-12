
#import <XCTest/XCTest.h>

@interface CCMConnectionTestBase : XCTestCase

- (NSURLConnection *)setUpDummyNSURLConnection;
- (NSURLConnection *)setUpDummyNSURLConnection:(id)requestArgConstraint;
- (NSData *)responseData;
- (id)responseMockWithStatusCode:(NSInteger)statusCode;

@end