#ifndef CCM_MAS_BUILD

#import <Foundation/Foundation.h>


@interface NSAppleEventDescriptor(EDAdditions)

+ (NSAppleEventDescriptor *)descriptorWithValue:(id)value;
+ (NSAppleEventDescriptor *)descriptorWithArray:(NSArray *)array;

- (id)naturalValue;
- (NSArray *)listValue;
- (NSDictionary *)recordValue;

@end

#endif
