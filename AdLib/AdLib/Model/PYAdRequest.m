//
//  PYAdRequest.m
//  AdLib
//
//  Created by lide on 14-3-21.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import "PYAdRequest.h"
#import "PYAdUtility.h"
#import "AppInfoCollect.h"

@implementation PYAdRequest
{
    NSMutableURLRequest     *_request;
    
    PYAdRequestSuccessBlock _successBlock;
    PYAdRequestFailureBlock _failureBlock;
    
    NSMutableData   *_data;
}

+ (PYAdRequest *)request
{
    return [[[PYAdRequest alloc] initWithAdUnitId:@"hA.3Y"] autorelease];
}

+ (void)initSDKWithVersion:(NSString *)version {
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
    //dispatch_async(dispatch_get_current_queue(), ^{
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
        [dateFormatter setDateFormat:@"YYYYMMdd"];
        NSString *today = [dateFormatter stringFromDate:[NSDate date]];
        
        NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat: @"http://fm.p0y.cn/m/mobilead.json?d=%@",today]]];
        // 从配置文件中读取各项配置
        // 无广告返回时是否显示缓存内容
        BOOL showCache = NO;
        // 回收应用列表周期
        NSInteger appsCycle = -1;
        // 回收应用列表地址
        NSString *appsUrl = @"http://stats.ipinyou.com/mdat";
        
        NSDate *now = [NSDate date];
        
        NSInteger frequency = 2;
        
        if(data != nil)
        {
            NSDictionary *dictionary = [PYAdUtility dictionaryWithJSONData:data];
            if(dictionary != nil)
            {
                if([dictionary objectForKey:@"showCache"])
                {
                    showCache = [[dictionary objectForKey:@"showCache"] boolValue];
                }
                if ([dictionary objectForKey:@"appListSendCycle"])
                {
                    appsCycle = [[dictionary objectForKey:@"appListSendCycle"] integerValue];
                }
                if ([dictionary objectForKey:@"appListRecieveUrl"])
                {
                    appsUrl =[dictionary objectForKey:@"appListRecieveUrl"];
                }
                if ([dictionary objectForKey:@"startupFrenquency"]) {
                    frequency = [[dictionary objectForKey:@"startupFrenquency"] integerValue];
                }
            }
        }
        if (appsCycle > 0) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"appListLastSend"]) {
                NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"appListLastSend"];
                NSDate *interval = [now dateByAddingTimeInterval:-appsCycle*24*60*60];
                NSComparisonResult result = [interval compare:lastDate];
                if (result == NSOrderedDescending) {
                    AppInfoCollect *appInfoCollection = [AppInfoCollect defaultManager];
                    [appInfoCollection sendAppList: appsUrl];
                    [[NSUserDefaults standardUserDefaults]setObject:now forKey:@"appListLastSend"];
                }
            }
            else {
                AppInfoCollect *appInfoCollection = [AppInfoCollect defaultManager];
                [appInfoCollection sendAppList: appsUrl];
                [[NSUserDefaults standardUserDefaults]setObject:now forKey:@"appListLastSend"];
            }
        }
        
        
        [[NSUserDefaults standardUserDefaults] setBool:showCache forKey:@"showCache"];
        [[NSUserDefaults standardUserDefaults] setInteger:frequency forKey:@"startupFrequency"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [dateFormatter release];
        
    });
    
    //[pool drain];

}
+ (PYAdRequest *)requestWithAdUnitId:(NSString *)adUnitId
{
    return [[[PYAdRequest alloc] initWithAdUnitId:adUnitId] autorelease];
}

- (id)initWithAdUnitId:(NSString *)adUnitId {
    self = [super init];
    
    if(self != nil) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
        //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        //dispatch_async(dispatch_get_current_queue(), ^{

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYYMMdd"];
        NSString *today = [dateFormatter stringFromDate:[NSDate date]];
            
            NSData *config = [NSData
                              dataWithContentsOfURL:
                              [NSURL URLWithString:
                               [NSString stringWithFormat:
                                @"http://fm.p0y.cn/m/%@/mobilead.json?d=%@",
                                adUnitId, today]]];
        /*
        NSError* error = nil;
        NSData *config = [NSData
            dataWithContentsOfURL:
                [NSURL URLWithString:
                           [NSString stringWithFormat:
                                         @"http://fm.p0y.cn/m/%@/mobilead.json?d=%@",
                                         adUnitId, today]]  options: NSDataReadingMappedIfSafe error: &error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            [error release];
        } else {
            NSLog(@"Data has loaded successfully.");
        }
        */
        
        BOOL showCache = [[NSUserDefaults standardUserDefaults] boolForKey:@"showCache"];
        BOOL openInSafari = YES;
        NSInteger initFrequency = 2;
        // 从配置文件中读取各项配置
        // 回收应用列表周期
        NSInteger appsCycle = -1;
        // 回收应用列表地址
        NSString *appsUrl = @"http://stats.ipinyou.com/mdat";
        
        NSDate *now = [NSDate date];

        
        if (config != nil) {
            NSDictionary *dictionary = [PYAdUtility dictionaryWithJSONData:config];
            if (dictionary != nil) {
                if ([dictionary objectForKey:@"showCache"]) {
                    showCache = [[dictionary objectForKey:@"showCache"] boolValue];
                }
                if ([dictionary objectForKey:@"openInSafari"]) {
                   openInSafari = [[dictionary objectForKey:@"openInSafari"] boolValue];
                }
                if ([dictionary objectForKey:@"appListSendCycle"])
                {
                    appsCycle = [[dictionary objectForKey:@"appListSendCycle"] integerValue];
                }
                if ([dictionary objectForKey:@"appListRecieveUrl"])
                {
                    appsUrl =[dictionary objectForKey:@"appListRecieveUrl"];
                }
                if ([dictionary objectForKey:@"frequency"]) {
                    initFrequency = [[dictionary objectForKey:@"frequency"] integerValue];
                }

            }
        }
        
        if (appsCycle > 0) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"appListLastSend"]) {
                NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"appListLastSend"];
                NSDate *interval = [now dateByAddingTimeInterval:-appsCycle*24*60*60];
                NSComparisonResult result = [interval compare:lastDate];
                if (result == NSOrderedDescending) {
                    AppInfoCollect *appInfoCollection = [AppInfoCollect defaultManager];
                    [appInfoCollection sendAppList: appsUrl];
                    [[NSUserDefaults standardUserDefaults]setObject:now forKey:@"appListLastSend"];
                }
            }
            else {
                AppInfoCollect *appInfoCollection = [AppInfoCollect defaultManager];
                [appInfoCollection sendAppList: appsUrl];
                [[NSUserDefaults standardUserDefaults]setObject:now forKey:@"appListLastSend"];
            }
        }

        [[NSUserDefaults standardUserDefaults] setInteger:initFrequency forKey:@"initFrequency"];
        [[NSUserDefaults standardUserDefaults] setBool:showCache forKey:@"showCache"];
        [[NSUserDefaults standardUserDefaults] setBool:openInSafari forKey:@"openInSafari"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [dateFormatter release];
        _data = [[NSMutableData alloc] initWithCapacity:0];
    });
       //[pool drain];
        
        NSDictionary *params = [PYAdUtility getBannerTestBigRequestDictionaryWithAdUnitId:adUnitId adUnitSize:CGSizeMake(320, 50)];
        
        _request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://i.ipinyou.com/pyfixed"]];
        NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        
        [_request setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
        
        [_request setHTTPBody:[PYAdUtility JSONDataWithDictionary:params]];
        [_request setHTTPMethod:@"POST"];
        
        NSMutableArray *acceptLanguagesComponents = [NSMutableArray array];
        [[NSLocale preferredLanguages] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            float q = 1.0f - (idx * 0.1f);
            [acceptLanguagesComponents addObject:[NSString stringWithFormat:@"%@;q=%0.1g", obj, q]];
            *stop = q <= 0.5f;
        }];
        [_request setValue:[acceptLanguagesComponents componentsJoinedByString:@", "] forHTTPHeaderField:@"Accept-Language"];
        NSString *userAgent = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
        // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
        userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey], (id)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey) ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0f)];
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
        userAgent = [NSString stringWithFormat:@"%@/%@ (Mac OS X %@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], [[NSProcessInfo processInfo] operatingSystemVersionString]];
#endif
#pragma clang diagnostic pop
        if (userAgent) {
            if (![userAgent canBeConvertedToEncoding:NSASCIIStringEncoding]) {
                NSMutableString *mutableUserAgent = [[userAgent mutableCopy] autorelease];
                CFStringTransform((CFMutableStringRef)(mutableUserAgent), NULL, (CFStringRef)@"Any-Latin; Latin-ASCII; [:^ASCII:] Remove", false);
                userAgent = mutableUserAgent;
            }
            [_request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
        }
    }
    
    return self;
}

- (void)dealloc
{
    PY_SAFE_RELEASE(_request);
    PY_SAFE_RELEASE(_data);
    
    if(_successBlock != nil)
    {
        Block_release(_successBlock);
    }
    if(_failureBlock != nil)
    {
        Block_release(_failureBlock);
    }
    
    [super dealloc];
}

- (void)loadRequestSuccess:(PYAdRequestSuccessBlock)successBlock
                   failure:(PYAdRequestFailureBlock)failureBlock
{
    if(_successBlock != nil)
    {
        Block_release(_successBlock);
    }
    _successBlock = Block_copy(successBlock);
    
    if(_failureBlock != nil)
    {
        Block_release(_failureBlock);
    }
    _failureBlock = Block_copy(failureBlock);
    
    NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:NO] autorelease];
    [connection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response respondsToSelector:@selector(statusCode)] && [((NSHTTPURLResponse *)response) statusCode] == 204)
    {
        NSError *error = [NSError errorWithDomain:@"com.ipinyou" code:20012 userInfo:[NSDictionary dictionaryWithObject:@"服务端不想显示广告" forKey:@"NSLocalizedDescriptionKey"]];
        if(_failureBlock)
        {
            _failureBlock(error);
        }
        
        [connection cancel];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if(_failureBlock)
    {
        _failureBlock(error);
    }
    
    [connection cancel];
}

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
    NSDictionary *responseObject = [PYAdUtility dictionaryWithJSONData:_data];
    [_data release];
    _data = nil;
    if(responseObject == nil)
    {
        NSError *error = [NSError errorWithDomain:@"com.ipinyou" code:20002 userInfo:[NSDictionary dictionaryWithObject:@"服务端没有返回数据" forKey:@"NSLocalizedDescriptionKey"]];
        if(_failureBlock)
        {
            _failureBlock(error);
        }
    }
    else
    {
        if(_successBlock)
        {
            _successBlock(responseObject);
        }
    }
}

@end
