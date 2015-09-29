//
//  PYAppManager.h
//  AdLib
//
//  Created by lide on 14-2-28.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PYAppManager : NSObject
{
    BOOL                _getFlag;
    NSMutableData       *_data;
}

@property (assign, nonatomic) NSUInteger trackId;
@property (assign, nonatomic) float price;

+ (PYAppManager *)defaultManager;

- (void)getAppInfo;

@end
