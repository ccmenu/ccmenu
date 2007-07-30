
#import <Cocoa/Cocoa.h>


@interface CCMProjectInfo : NSObject <NSCopying>
{
	NSString		*projectName;
	NSString		*buildStatus;
	NSCalendarDate  *lastBuildDate;
}

+ (NSArray *)infosFromXmlData:(NSData *)xml;

- (id)initWithProjectName:(NSString *)aName buildStatus:(NSString *)aStatus lastBuildDate:(NSCalendarDate *)aDate;

- (NSString *)projectName;

- (NSString *)buildStatus;
- (BOOL)isFailed;

- (NSCalendarDate *)lastBuildDate;
- (NSString *)timeSinceLastBuild;

@end

extern NSString *CCMPassedStatus;
extern NSString *CCMFailedStatus;
