//
//  PYOfflineSyncManager.m
//  AdLib
//
//  Created by lide on 14-3-26.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import "PYOfflineSyncManager.h"
#import "PYAdUtility.h"
#import "PYModelRequest.h"

@implementation PYOfflineSyncManager

static id defaultManager = nil;
+ (PYOfflineSyncManager *)defaultManager
{
    @synchronized(defaultManager){
        if(defaultManager == nil)
        {
            defaultManager = [[PYOfflineSyncManager alloc] init];
        }
    }
    return defaultManager;
}

- (id)init
{
    self = [super init];
    if(self != nil)
    {
        _requestArray = [[NSMutableArray alloc] initWithCapacity:0];
        [_requestArray addObjectsFromArray:[PYAdUtility unarchiveDataFromCache:@"AsyncRequestList"]];
        
        _tempArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        _syncEnable = YES;
    }
    
    return self;
}

- (void)dealloc
{
    PY_SAFE_RELEASE(_requestArray);
    PY_SAFE_RELEASE(_tempArray);
    
    [super dealloc];
}

- (void)addOfflineModelRequest:(PYModelRequest *)modelRequest
{
    [_requestArray addObject:modelRequest];
    [PYAdUtility archiveData:_requestArray IntoCache:@"AsyncRequestList"];
}

- (void)prepareToSyncOfflineRequest
{
    if(_syncEnable)
    {
        _syncEnable = NO;
        [self performSelector:@selector(startSyncOfflineRequest) withObject:nil afterDelay:600];
    }
}

- (void)startSyncOfflineRequest
{
    [self syncOfflineRequest];
    _syncEnable = NO;
    [self performSelector:@selector(finishSyncOfflineRequest) withObject:nil afterDelay:3600/*86400*/];
}

- (void)finishSyncOfflineRequest
{
    _syncEnable = YES;
}

- (void)syncOfflineRequest
{
    if([_requestArray count] > 0)
    {
        PYModelRequest *request = [_requestArray objectAtIndex:0];
        [request loadRequestSuccess:^(id responseObject) {
            [_requestArray removeObject:request];
            [self syncOfflineRequest];
        } failure:^(NSError *error) {
            [_tempArray addObject:request];
            [_requestArray removeObject:request];
            [self syncOfflineRequest];
        }];
    }
    else
    {
        [_requestArray addObjectsFromArray:_tempArray];
        [PYAdUtility archiveData:_requestArray IntoCache:@"AsyncRequestList"];
        [_tempArray removeAllObjects];
    }
}

@end