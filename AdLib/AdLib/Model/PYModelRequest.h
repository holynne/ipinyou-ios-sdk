//
//  PYModelRequest.h
//  AdLib
//
//  Created by lide on 14-3-26.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PYModelRequestSuccessBlock)(id responseObject);
typedef void (^PYModelRequestFailureBlock)(NSError *error);

@interface PYModelRequest : NSObject <NSCoding, NSCopying>
{
    NSString        *_requestURLString;
}

@property (retain, nonatomic) NSString *requestURLString;

- (void)loadRequestSuccess:(PYModelRequestSuccessBlock)successBlock
                   failure:(PYModelRequestFailureBlock)failureBlock;

@end
