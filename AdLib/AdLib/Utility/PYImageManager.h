//
//  PYImageManager.h
//  AdLib
//
//  Created by lide on 14-2-24.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PYImageSuccessBlock)(UIImage *image, BOOL finished);
typedef void (^PYImageFailureBlock)(NSError *error);

@interface PYImageManager : NSObject
{
    PYImageSuccessBlock     _successBlock;
    PYImageFailureBlock     _failureBlock;
}

@property (strong, nonatomic) NSMutableURLRequest *request;

@property (assign, nonatomic) long long expectedSize;
@property (strong, nonatomic) NSMutableData *imageData;

+ (PYImageManager *)defaultManager;

- (void)downloadImageWithURL:(NSString *)imageURL
                     success:(PYImageSuccessBlock)successBlock
                     failure:(PYImageFailureBlock)failureBlock;

@end
