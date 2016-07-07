//
//  CCMJsonServerStatusReader.m
//  CCMenu
//
//  Created by Travis Bader on 7/6/16.
//  Copyright © 2016 ThoughtWorks. All rights reserved.
//

#import "CCMBotsServerStatusReader.h"

@implementation CCMBotsServerStatusReader {
    NSData* _responseData;
    NSString* _baseURL;
}

-(id)initWithServerResponse:(NSData*)data fromBaseURL:(NSString*)url {
    self = [super init];
    if (self) {
        _responseData = [data copy];
        _baseURL = [url copy];
    }
    return self;
}

-(void)dealloc {
    [_responseData release];
    [_baseURL release];
    [super dealloc];
}

-(NSArray*)readProjectInfos:(NSError**)errorPtr {
//    return @[];
    NSMutableArray* integrations = [NSMutableArray new];
    NSDictionary* parsedJson = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:errorPtr];

    for (NSDictionary* result in parsedJson[@"results"]) {
        NSMutableDictionary* integration = [[NSMutableDictionary new] retain];
        
        integration[@"name"] = result[@"name"];
        integration[@"lastBuildLabel"] = ((NSNumber*)result[@"integration_counter"]).stringValue;
        integration[@"webUrl"] = [NSString stringWithFormat:@"%@/bots/latest/%@/", [self webUrlFromBaseXcodeURL:_baseURL], result[@"tinyID"]];
        
        NSString* integrationURL = [NSString stringWithFormat:@"%@/%@/integrations?last=1", _baseURL, result[@"_id"]];
        NSError* error = nil;
        NSData* integrationData = [NSData dataWithContentsOfURL:[NSURL URLWithString:integrationURL]];
        NSDictionary* integrationJSON = [NSJSONSerialization JSONObjectWithData:integrationData options:0 error:&error];
        NSDictionary* integrationResult = ((NSArray*)integrationJSON[@"results"]).firstObject;
        
        if (!error) {
            integration[@"lastBuildTime"] = integrationResult[@"endedTime"];
            
            NSString* activity = [self activityFromJson:integrationResult];
            integration[@"activity"] = activity;
            integration[@"lastBuildStatus"] = activity;
            if ([activity isEqualToString:@"Building"]) {
                integration[@"lastBuildStatus"] = nil;//@"Success";
            }
        }
        
        [integrations addObject:integration];
    }
    return integrations;
}

-(NSString*)webUrlFromBaseXcodeURL:(NSString*)baseURL {
    NSURL* oldURL = [NSURL URLWithString:baseURL];
    return [NSString stringWithFormat:@"%@://%@/xcode", oldURL.scheme, oldURL.host];
}

-(NSString*)activityFromJson:(NSDictionary*)dictionary {
    NSString* activity = dictionary[@"currentStep"];
    NSString* resultString = dictionary[@"result"];
    NSLog(@"activity %@, result %@", activity, resultString);
    if ([activity isEqualToString:@"completed"]) {
        if (resultString == nil || [resultString isEqualToString:@"trigger-error"] || [resultString isEqualToString:@"canceled"]) {
            return @"Failure";
        }
        else {
            return  @"Success";
        }
    }
    return @"Building";
}

@end
