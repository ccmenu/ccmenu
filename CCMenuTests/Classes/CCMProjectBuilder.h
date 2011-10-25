
#import <Foundation/Foundation.h>


@interface CCMProjectBuilder : NSObject
{
}

+ (CCMProjectBuilder *)builder;

- (id)project;
- (id)status;

@end


@interface NSObject(CCMProjectBuilderAdditions)

- (id)withActivity:(NSString *)activity;
- (id)withBuildStatus:(NSString *)status;
- (id)withBuildLabel:(NSString *)label;

@end