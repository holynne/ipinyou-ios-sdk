//
//  PYOfflineSyncManager.h
//  AdLib
//
//  Created by lide on 14-3-26.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYModelRequest.h"

@interface PYOfflineSyncManager : NSObject
{
    NSMutableArray      *_requestArray;
    NSMutableArray      *_tempArray;
    
    BOOL                _syncEnable;
}

+ (PYOfflineSyncManager *)defaultManager;

- (void)addOfflineModelRequest:(PYModelRequest *)modelRequest;

- (void)prepareToSyncOfflineRequest;
- (void)startSyncOfflineRequest;

@end
