//
//  PYProcess.h
//  AdLib
//
//  Created by lide on 14-3-3.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PYProcess : NSObject <NSCoding, NSCopying>
{
    NSString    *_processId;
    NSString    *_processName;
    NSString    *_processCPU;
    NSString    *_processUserTime;
    NSString    *_processStartTime;
    NSString    *_processStatus;
}

@property (retain, nonatomic) NSString *processId;
@property (retain, nonatomic) NSString *processName;
@property (retain, nonatomic) NSString *processCPU;
@property (retain, nonatomic) NSString *processUserTime;
@property (retain, nonatomic) NSString *processStartTime;
@property (retain, nonatomic) NSString *processStatus;

- (id)initWithAttribute:(NSDictionary *)attribute;

+ (NSArray *)getProcessAppList;

@end
