
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "NSWorkspace+CCMAdditions.h"


@interface NSWorkspace_CCMAdditionsTest : XCTestCase
@end

@implementation NSWorkspace_CCMAdditionsTest

- (void)testOpensURL
{
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    id mock = OCMPartialMock(workspace);
    OCMStub([mock openURL:[OCMArg any]]); // stub to suppress call to real workspace object

    [workspace openURLString:@"http://localhost/test"];

    OCMVerify([mock openURL:[NSURL URLWithString:@"http://localhost/test"]]);
}


- (void)testEncodesURLWithSpecialCharactersAndOpensIt
{
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    id mock = OCMPartialMock(workspace);
    OCMStub([mock openURL:[OCMArg any]]);

    [workspace openURLString:@"http://localhost/test with space"];

    OCMVerify([mock openURL:[NSURL URLWithString:@"http://localhost/test%20with%20space"]]);
}


- (void)testDoesNotEncodeAlreadyEncodedURLAndOpensIt
{
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    id mock = OCMPartialMock(workspace);
    OCMStub([mock openURL:[OCMArg any]]);

    [workspace openURLString:@"http://localhost/test%20with%20space"];

    OCMVerify([mock openURL:[NSURL URLWithString:@"http://localhost/test%20with%20space"]]);
}


- (void)testEncodesURLWithBrokenEncodingAndOpensIt
{
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    id mock = OCMPartialMock(workspace);
    OCMStub([mock openURL:[OCMArg any]]);

    [workspace openURLString:@"http://localhost/broken%2"];

    OCMVerify([mock openURL:[NSURL URLWithString:@"http://localhost/broken%252"]]);
}

@end