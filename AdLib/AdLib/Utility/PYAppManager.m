//
//  PYAppManager.m
//  AdLib
//
//  Created by lide on 14-2-28.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import "PYAppManager.h"
#import "PYAdUtility.h"

@implementation PYAppManager

@synthesize trackId;
@synthesize price;

static id defaultManager = nil;
+ (PYAppManager *)defaultManager
{
    @synchronized(defaultManager){
        if(defaultManager == nil)
        {
            defaultManager = [[PYAppManager alloc] init];
        }
    }
    return defaultManager;
}

- (id)init
{
    self = [super init];
    if(self != nil)
    {
        _getFlag = NO;
    }
    
    return self;
}

- (void)dealloc
{
    PY_SAFE_RELEASE(_data);
    
    [super dealloc];
}

#pragma mark - public

- (void)getAppInfo
{
    if(_getFlag)
    {
        return;
    }
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", bundleIdentifier]]];
    
    NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    [connection start];
    
    [request release];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(_data == nil)
    {
        _data = [[NSMutableData alloc] initWithCapacity:0];
    }
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *dictionary = [PYAdUtility dictionaryWithJSONData:_data];
    
    if(_data != nil)
    {
        PY_SAFE_RELEASE(_data);
    }

    NSArray *array = [dictionary objectForKey:@"results"];
    if(array && [array isKindOfClass:[NSArray class]] && [array count] > 0)
    {
        _getFlag = YES;
        
        NSDictionary *result = [array objectAtIndex:0];
        if([result objectForKey:@"trackId"])
        {
            self.trackId = [[result objectForKey:@"trackId"] integerValue];
        }
        if([result objectForKey:@"price"])
        {
            self.price = [[result objectForKey:@"price"] floatValue];
        }
    }
}

@end
