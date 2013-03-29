/*
 
 based on NSAppleScript+HandlerCalls.h by Buzz Andersen
 More information at: http://www.scifihifi.com/weblog/mac/Cocoa-AppleEvent-Handlers.html
 
 */

#import <Foundation/Foundation.h>
#import "NSAppleScript+EDAdditions.h"
#import "NSAppleEventDescriptor+EDAdditions.h"


@implementation NSAppleScript(EDAdditions)

//---------------------------------------------------------------------------------------
//	factory methods
//---------------------------------------------------------------------------------------

+ (NSAppleScript *)scriptWithName:(NSString *)name
{
    NSString *scriptPath = [[NSBundle mainBundle] pathForResource:name ofType:@"scpt"];
    NSURL *scriptURL = [NSURL fileURLWithPath:scriptPath];
	
    NSDictionary *errorInfo = nil;
	NSAppleScript *script = [[[NSAppleScript alloc] initWithContentsOfURL:scriptURL error:&errorInfo] autorelease];    
    if(errorInfo != nil)
		[[NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Error while loading AppleScript %@", name] userInfo:errorInfo] raise];
	return script;
}


//---------------------------------------------------------------------------------------
// callHandler wrappers
//---------------------------------------------------------------------------------------

- (id)callHandler:(NSString *)handler
{
	return [self callHandler:handler withArguments:[NSArray array]];
}

- (id)callHandler:(NSString *)handler withArgument:(id)argument
{
	return [self callHandler:handler withArguments:[NSArray arrayWithObject:argument]];
}

- (id)callHandler:(NSString *)handler withArguments:(NSArray *)arguments
{
    return [self callHandler:handler withArguments:arguments errorInfo:NULL];
}

- (id)callHandler:(NSString *) handler withArguments:(NSArray *)arguments errorInfo:(NSDictionary **) errorInfo 
{
    NSAppleEventDescriptor* argDescriptor;
    NSAppleEventDescriptor* event; 
    NSAppleEventDescriptor* targetAddress; 
    NSAppleEventDescriptor* subroutineDescriptor; 
    NSAppleEventDescriptor* result;

    argDescriptor = [NSAppleEventDescriptor descriptorWithValue:arguments];

    /* This will be a self-targeted AppleEvent, so we need to identify ourselves using our process id */
    int pid = [[NSProcessInfo processInfo] processIdentifier];
    targetAddress = [[NSAppleEventDescriptor alloc] initWithDescriptorType: typeKernelProcessID bytes: &pid length: sizeof(pid)];
    
    /* Set up our root AppleEvent descriptor: a subroutine call (psbr) */
    event = [[NSAppleEventDescriptor alloc] initWithEventClass: 'ascr' eventID: 'psbr' targetDescriptor: targetAddress returnID: kAutoGenerateReturnID transactionID: kAnyTransactionID];
    
    /* Set up an AppleEvent descriptor containing the subroutine (handler) name */
    subroutineDescriptor = [NSAppleEventDescriptor descriptorWithString: handler];
    [event setParamDescriptor: subroutineDescriptor forKeyword: 'snam'];

    /* Add the provided arguments to the handler call */
    [event setParamDescriptor: argDescriptor forKeyword: keyDirectObject];
    
    /* Execute the handler */
    result = [self executeAppleEvent: event error: errorInfo];

    [targetAddress release];
    [event release];
    
    return nil; //[result naturalValue];
}

@end
