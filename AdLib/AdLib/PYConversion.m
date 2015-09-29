//
//  PYConversion.m
//  AdLib
//
//  Created by darren on 14-4-16.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import "PYConversion.h"
#import "PYAdUtility.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <OpenFingerPrint.h>
#ifdef __IPHONE_6_0
#import <AdSupport/AdSupport.h>
#endif


@implementation PYConversion

static NSString *requestUrl = @"http://stats.ipinyou.com/mcvt";
static NSMutableDictionary *deviceInfo;
static id manager = nil;
+ (PYConversion *)defaultManager
{
    @synchronized(manager){
        if(manager == nil)
        {
            manager = [[PYConversion alloc] init];
        }
    }
    return manager;
}

- (void)noticeConversionWithParamA:(NSString *)a conversionType:(ConversionType)type {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        // app already launched
        //NSLog(@"app already launched!");
        if (type != PY_DownLoad) {
            [self threadSendParamToPinYou:a conversionType:type];
        }
    }
    else {
        //NSLog(@"app first launched!");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self threadSendParamToPinYou:a conversionType:type];
    }
    
}

- (void)threadSendParamToPinYou:(NSString *)a conversionType:(ConversionType)type {
    //BOOL networkConnected = [self isNetworkAvailable];
    //if (networkConnected) {
        [self sendParam:a conversionType:type];
//    } else {
//        NSLog(@"network Status is broken");
//    }
}

- (void) sendParam:(NSString *)a conversionType:(ConversionType )type {
    @try {
    [PYAdUtility getAppList:^(NSArray *appIdArray) {
        deviceInfo = [self getDeviceInfo];
        [deviceInfo setValue:a forKey:@"a"];
        [deviceInfo setValue:[NSNumber numberWithInt:type] forKey:@"gl"];
        NSString *appList = [appIdArray componentsJoinedByString:@","];
        NSString *extendParam = [NSString stringWithFormat:@"flag=;applist=%@",appList];
        [deviceInfo setValue:extendParam forKey:@"et"];
        
        NSURL *requestUrlToPinyou = [NSURL URLWithString: requestUrl];
        // post json data
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:requestUrlToPinyou];
        [urlRequest setTimeoutInterval:60.0f];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        //NSData *jsonData = [NSJSONSerialization dataWithJSONObject:deviceInfo options:NSJSONWritingPrettyPrinted error:&error];
        NSData *jsonData = [PYAdUtility JSONDataWithDictionary:deviceInfo];
        [urlRequest setHTTPBody:jsonData ];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        [connection start];
    } failure:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}
@catch (NSException *exception) {
    NSLog(@"Error in sendParam!!");
}
}

//update by wujun 2014-7-16 for define type
- (void)noticeConversionWithParamA:(NSString *)a conversionTypeString:(NSString *)type {
    
    //NSLog(@"app first launched!");
    //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    [self threadSendParamToPinYou:a conversionTypeString:type orderNo:nil];
}

- (void)noticeConversionWithParamA:(NSString *)a conversionTypeString:(NSString *)type
                           orderNo:(NSString *)orderNo;
{
    
    [self threadSendParamToPinYou:a conversionTypeString:type orderNo:orderNo];
}

- (void)threadSendParamToPinYou:(NSString *)a conversionTypeString:(NSString *)type
                        orderNo:(NSString *)orderNo;
{
    //BOOL networkConnected = [self isNetworkAvailable];
    //if (networkConnected) {
    [self sendParam:a conversionTypeString:type orderNo:orderNo];
    //    } else {
    //        NSLog(@"network Status is broken");
    //    }
}

- (void) sendParam:(NSString *)a conversionTypeString:(NSString * )type
           orderNo:(NSString *)orderNo;
{
    @try {
        [PYAdUtility getAppList:^(NSArray *appIdArray) {
            deviceInfo = [self getDeviceInfo];
            [deviceInfo setValue:a forKey:@"a"];
            [deviceInfo setValue:type forKey:@"gl"];
            NSString *appList = [appIdArray componentsJoinedByString:@","];
            NSString *extendParam = [NSString stringWithFormat:@"flag=;applist=%@",appList];
            [deviceInfo setValue:extendParam forKey:@"et"];
            if(orderNo!=nil){
                [deviceInfo setValue:orderNo forKey:@"sn"];
            }
            NSString *fp = [OpenFingerPrint getFp];
            if(fp!=nil){
                [deviceInfo setValue:fp forKey:@"fp"];
            }
            
            NSURL *requestUrlToPinyou = [NSURL URLWithString: requestUrl];
            // post json data
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:requestUrlToPinyou];
            [urlRequest setTimeoutInterval:60.0f];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            //NSData *jsonData = [NSJSONSerialization dataWithJSONObject:deviceInfo options:NSJSONWritingPrettyPrinted error:&error];
            NSData *jsonData = [PYAdUtility JSONDataWithDictionary:deviceInfo];
            [urlRequest setHTTPBody:jsonData ];
            
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            [connection start];
        } failure:^(NSError *error) {
            NSLog(@"%@",error.localizedDescription);
            deviceInfo = [self getDeviceInfo];
            [deviceInfo setValue:a forKey:@"a"];
            [deviceInfo setValue:type forKey:@"gl"];
            NSString *appList = @"";
            NSString *extendParam = [NSString stringWithFormat:@"flag=;applist=%@",appList];
            [deviceInfo setValue:extendParam forKey:@"et"];
            if(orderNo!=nil){
                [deviceInfo setValue:orderNo forKey:@"sn"];
            }
            NSString *fp = [OpenFingerPrint getFp];
            if(fp!=nil){
                [deviceInfo setValue:fp forKey:@"fp"];
            }
            
            NSURL *requestUrlToPinyou = [NSURL URLWithString: requestUrl];
            // post json data
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:requestUrlToPinyou];
            [urlRequest setTimeoutInterval:60.0f];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            //NSData *jsonData = [NSJSONSerialization dataWithJSONObject:deviceInfo options:NSJSONWritingPrettyPrinted error:&error];
            NSData *jsonData = [PYAdUtility JSONDataWithDictionary:deviceInfo];
            [urlRequest setHTTPBody:jsonData ];
            
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            [connection start];
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"Error in sendParam!!");
    }
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Sending request to Pinyou has error!");
    [connection cancel];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response respondsToSelector:@selector(statusCode)] && [(NSHTTPURLResponse *)response statusCode] == 200) {
        NSLog(@"%@",@"Sending request to Pinyou Completed!!");
    }
    [connection cancel];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Sending request to Pinyou Completed!!");
    [connection cancel];
}

/*
 获取设备的基本信息
 */
- (NSMutableDictionary *) getDeviceInfo {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用名称
    NSString *applicationName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *operationSystem = [[UIDevice currentDevice] systemName];
    NSString *operationSystemVersion = [[UIDevice currentDevice] systemVersion];
    NSString *operationSystemInfo = [operationSystem stringByAppendingFormat:@", %@",operationSystemVersion]; //操作系统版本
    
    NSString *idfa = [PYAdUtility getDeviceIDFA];
    
    NSString *deviceModel = [[UIDevice currentDevice] model];
    NSString *networkId = [self getNetworkId];//运营商类型[self getCarrier]
    NSString *deviceType = @"Phone"; //设备
      @try {
    if(deviceModel!=nil && [deviceModel rangeOfString:@"iPhone"].location != NSNotFound){
        deviceType=@"Phone";
    }else if (deviceModel!=nil && [deviceModel rangeOfString:@"iPad"].location != NSNotFound) {
        deviceType=@"Tablet";
    }else {
        deviceType=@"Mobile";
    }
}
@catch (NSException *exception) {
    NSLog(@"Error in getDeviceInfo!!");
}
    NSString *macAddressUnderWifi = [PYAdUtility getMacAddress];
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                operationSystemInfo,@"os",
                                idfa,@"ia",
                                deviceType,@"dt",
                                @"APPLE",@"db",
                                applicationName,@"an",
                                macAddressUnderWifi,@"wm",
                                networkId,@"mc",
                                @"",@"bm",
                                @"",@"ud",
                                nil];
    return [tmp autorelease];
}

- (NSString *)getNetworkId
{
    if([PYAdUtility connectedToWiFi])
    {
        return @"Wifi";
    }
    else
    {
        NSString *string = [PYAdUtility carrierName];
        
        if(string != nil)
        {
            if([string isEqualToString:@"中国移动"])
            {
                return @"Mobile";
            }
            else if([string isEqualToString:@"中国电信"])
            {
                return @"Unicom";
            }
            else if([string isEqualToString:@"中国联通"])
            {
                return @"Telecom";
            }
        }
        return @"Unknown";
    }
}

/**
 * 获取运营商信息

- (NSString *)getCarrier {
    CTTelephonyNetworkInfo *netInfo = [[[CTTelephonyNetworkInfo alloc] init] autorelease];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    //NSString *imsi;
    
    if (carrier == nil || [[carrier mobileNetworkCode] length] == 0) {
        return @"Unknown";
    }
    
    NSString *mcc = [carrier mobileCountryCode];
    
    NSString *mnc = [carrier mobileNetworkCode];

    NSLog(@"mcc:%@",mcc);
    NSLog(@"mnc:%@",mnc);
    
    //imsi = [NSString stringWithFormat:@"%@%@", mcc, mnc];
    if (mcc == nil || mnc == nil || [mcc isEqualToString:@"SIM Not Inserted"]  || [mnc isEqualToString:@"SIM Not Inserted"] ) {
        return @"Unknown";
    }
    else {
        @try {
        if ([mcc isEqualToString:@"460"]) {
            NSInteger MNC = [mnc intValue];
            switch (MNC) {
                case 00:
                case 02:
                case 07:
                    return @"Mobile";
                    break;
                case 01:
                case 06:
                    return @"Unicom";
                    break;
                case 03:
                case 05:
                    return @"Telecom";
                    break;
                case 20:
                    return @"Tietong";
                    break;
                default:
                    break;
            }
        }
        }
        @catch (NSException *exception) {
            NSLog(@"Error in getCarrier!!");
        }
    }
    return @"Unknown";
}
 */
 
@end
