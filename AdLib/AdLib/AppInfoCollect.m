//
//  AppInfoCollect.m
//  AdLib
//
//  Created by darren on 14-5-22.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import "AppInfoCollect.h"
#import "PYAdUtility.h"

@implementation AppInfoCollect

static id manager;
+ (AppInfoCollect *)defaultManager {
    @synchronized(manager) {
        if (manager == nil) {
            manager = [[AppInfoCollect alloc] init];
        }
    }
    return manager;
}


- (void)sendAppList:(NSString *)appListRecivedUrl {
    
    [PYAdUtility getAppList:^(NSArray *appIdArray) {
        NSDictionary *deviceInfo = [PYAdUtility getDeviceInfoDictionary];
        
        NSString *appList = [appIdArray componentsJoinedByString:@","];
        
        [deviceInfo setValue:appList forKey:@"app"];
        [deviceInfo setValue:appList forKey:@"run"];
        
        NSURL *requestUrlToPinyou = [NSURL URLWithString:appListRecivedUrl];
        // post json data
        NSMutableURLRequest *urlRequest =
        [NSMutableURLRequest requestWithURL:requestUrlToPinyou];
        [urlRequest setTimeoutInterval:60.0f];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        // NSData *jsonData = [NSJSONSerialization dataWithJSONObject:deviceInfo
        // options:NSJSONWritingPrettyPrinted error:&error];
        NSData *jsonData = [PYAdUtility JSONDataWithDictionary:deviceInfo];
        [urlRequest setHTTPBody:jsonData];
        
        NSURLConnection *connection =
        [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        [connection start];
    }
                    failure:^(NSError *error) { NSLog(@"%@", error.localizedDescription); }];
}
@end
