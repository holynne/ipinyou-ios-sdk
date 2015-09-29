//
//  AppInfoCollect.h
//  AdLib
//
//  Created by darren on 14-5-22.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppInfoCollect : NSObject

+ (AppInfoCollect *)defaultManager;
- (void) sendAppList:(NSString *)url;

@end
