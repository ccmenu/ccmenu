
#import <OCMock/OCMock.h>
#import "CCMProjectBuilder.h"
#import "CCMProject.h"


@implementation CCMProjectBuilder

+ (CCMProjectBuilder *)builder
{
    return [[[CCMProjectBuilder alloc] init] autorelease];
}

- (id)project
{
    CCMProject *project = [[[CCMProject alloc] initWithName:@"connectfour"] autorelease];
    [project setStatus:[self status]];
    return project;
}

- (id)status
{
    return [[[CCMProjectStatus alloc] initWithDictionary:[NSDictionary dictionary]] autorelease];
}

@end


@implementation CCMProject(CCMProjectBuilderAdditions)

- (id)withActivity:(NSString *)activity
{
    [[self status] withActivity:activity];
    return self;
}

- (id)withBuildStatus:(NSString *)buildStatus
{
    [[self status] withBuildStatus:buildStatus];
    return self;
}

- (id)withBuildLabel:(NSString *)buildLabel
{
    [[self status] withBuildLabel:buildLabel];
    return self;
}

@end

@implementation CCMProjectStatus(CCMProjectBuilderAdditions)

- (void)addValue:(id)value forKey:(NSString *)key
{
    NSMutableDictionary *copy = [info mutableCopy];
    [copy setObject:value forKey:key];
    [info autorelease];
    info = copy;
}

- (id)withActivity:(NSString *)activity
{
    [self addValue:activity forKey:@"activity"];
    return self;
}

- (id)withBuildStatus:(NSString *)buildStatus
{
    [self addValue:buildStatus forKey:@"lastBuildStatus"];
    return self;
}

- (id)withBuildLabel:(NSString *)buildLabel
{
    [self addValue:buildLabel forKey:@"lastBuildLabel"];
    return self;
}

@end
