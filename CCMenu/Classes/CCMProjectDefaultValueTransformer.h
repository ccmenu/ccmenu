#import <Foundation/Foundation.h>

@interface CCMProjectDefaultValueTransformer : NSValueTransformer
- (id)transformedValue:(id)value isSelected:(BOOL)isSelected;
@end

extern NSString *CCMProjectDefaultValueTransformerName;
