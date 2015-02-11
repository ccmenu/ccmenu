
#import <XCTest/XCTest.h>

@interface CCMConnectionTestBase : XCTestCase

- (NSURLConnection *)setUpDummyNSURLConnection;
- (NSURLConnection *)setUpDummyNSURLConnection:(OCMArg *)requestArgConstraint;
- (NSData *)responseData;
- (id)responseMockWithStatusCode:(NSInteger)statusCode;

@end