//
//  AdUtility.m
//  AdLib
//
//  Created by lide on 14-2-18.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import "PYAdUtility.h"
#import "PYJSONSerializer.h"
#import "PYJSONDeserializer.h"
#import "PYAppManager.h"

#import "OpenFingerPrint.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#ifdef __IPHONE_6_0
#import <AdSupport/AdSupport.h>
#endif

typedef enum {
    NETWORK_TYPE_NONE= 0,
    NETWORK_TYPE_WIFI= 1,
    NETWORK_TYPE_3G= 2,
    NETWORK_TYPE_2G= 3,
}NETWORK_TYPE;

@implementation PYAdUtility

//JSON解析方法
+ (NSData *)JSONDataWithDictionary:(NSDictionary *)dictionary
{
    @try {
    if([UIDevice currentDevice].systemVersion.floatValue > 5.0)
    {
        return [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    }
    else
    {
        return [[PYJSONSerializer serializer] serializeDictionary:dictionary error:nil];
    }
}
@catch (NSException *exception) {
    NSLog(@"Error in JSONDataWithDictionary!!");
    
}
}

+ (id)dictionaryWithJSONData:(NSData *)data
{
@try {
    if([UIDevice currentDevice].systemVersion.floatValue > 5.0)
    {
        return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    }
    else
    {
        return ([[PYJSONDeserializer deserializer] deserialize:data error:nil]);
    }
}
@catch (NSException *exception) {
    NSLog(@"Error in dictionaryWithJSONData!!");
}
}

//从剪切板获取数据
+ (NSData *)dataFromPasteBoardWithType:(NSString *)type
{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    
    return [pasteBoard dataForPasteboardType:type];
}

+ (void)setDataToPasteBoard:(NSData *)data type:(NSString *)type
{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    
    [pasteBoard setData:data forPasteboardType:type];
}

+ (NSString *)getSystemName
{
    return [[UIDevice currentDevice] systemName];
}

+ (NSDictionary *)getSystemVersion
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSString *versionString = [[UIDevice currentDevice] systemVersion];
    NSArray *versionArray = [versionString componentsSeparatedByString:@"."];
    
    switch ([versionArray count]) {
        case 1:
        {
            [dict setObject:[versionArray objectAtIndex:0] forKey:@"major_version"];
        }
            break;
        case 2:
        {
            [dict setObject:[versionArray objectAtIndex:0] forKey:@"major_version"];
            [dict setObject:[versionArray objectAtIndex:1] forKey:@"minor_version"];
        }
            break;
        case 3:
        {
            [dict setObject:[versionArray objectAtIndex:0] forKey:@"major_version"];
            [dict setObject:[versionArray objectAtIndex:1] forKey:@"minor_version"];
            [dict setObject:[versionArray objectAtIndex:2] forKey:@"micro_version"];
        }
            break;
        default:
        {
            [dict setObject:@"0" forKey:@"major_version"];
        }
            break;
    }
    
    return dict;
}
+ (NSString *)getOsAndVersion
{
    NSString *operationSystem = [[UIDevice currentDevice] systemName];
    NSString *operationSystemVersion = [[UIDevice currentDevice] systemVersion];
    NSString *operationSystemInfo = [operationSystem stringByAppendingFormat:@", %@",operationSystemVersion];
    return operationSystemInfo;
}

+ (NSString *)getDeviceModelName
{
    return [[UIDevice currentDevice] model];
}

+ (NSString *)getUserAgent
{
    UIWebView *webView = [[[UIWebView alloc] initWithFrame:CGRectZero] autorelease];
    NSString *secretAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    return secretAgent;
}

+ (NSString *)getSystemLanguage
{
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *language = [currentLocale objectForKey:NSLocaleLanguageCode];
    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
    
    return [NSString stringWithFormat:@"%@_%@", language, countryCode];
}

+ (NSInteger)getScreenWidth
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat scale = [UIScreen mainScreen].scale;
    
    return width * scale;
}

+ (NSInteger)getScreenHeight
{
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat scale = [UIScreen mainScreen].scale;
    
    return height * scale;
}

+ (NSString *)getScreenOrientation
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    switch (orientation) {
        case UIDeviceOrientationUnknown:
        {
            return @"SCREEN_ORIENTATION_UNKNOWN";
        }
            break;
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
        {
            return @"SCREEN_ORIENTATION_PORTRAIT";
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
        {
            return @"SCREEN_ORIENTATION_LANDSCAPE";
        }
            break;
        default:
        {
            return @"SCREEN_ORIENTATION_UNKNOWN";
        }
            break;
    }
    
    return @"SCREEN_ORIENTATION_UNKNOWN";
}

+ (NSString *)getDeviceIDFA
{
#ifdef __IPHONE_6_0
    id object = [[[NSClassFromString(@"ASIdentifierManager") alloc] init] autorelease];
    if(object != nil)
    {
        if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
            return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        }
    }
    return @" ";
#else
    return @" ";
#endif
}

+ (NSString *)getMacAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        NSLog(@"Error: %@", errorFlag);
        free(msgBuffer);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
//    NSLog(@"Mac Address: %@", macAddressString);
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}

// Connected to WiFi?
+ (BOOL)connectedToWiFi
{
    // Check if we're connected to WiFi
    NSString *WiFiAddress = [PYAdUtility wiFiIPAddress];
    // Check if the string is populated
    if (WiFiAddress == nil || WiFiAddress.length <= 0) {
        // Nothing found
        return false;
    } else {
        // WiFi in use
        return true;
    }
}

// Get WiFi IP Address
+ (NSString *)wiFiIPAddress {
    // Get the WiFi IP Address
    @try {
        // Set a string for the address
        NSString *IPAddress = nil;
        // Set up structs to hold the interfaces and the temporary address
        struct ifaddrs *Interfaces;
        struct ifaddrs *Temp;
        // Set up int for success or fail
        int Status = 0;
        
        // Get all the network interfaces
        Status = getifaddrs(&Interfaces);
        
        // If it's 0, then it's good
        if (Status == 0)
        {
            // Loop through the list of interfaces
            Temp = Interfaces;
            
            // Run through it while it's still available
            while(Temp != NULL)
            {
                // If the temp interface is a valid interface
                if(Temp->ifa_addr->sa_family == AF_INET)
                {
                    // Check if the interface is WiFi
                    if([[NSString stringWithUTF8String:Temp->ifa_name] isEqualToString:@"en0"])
                    {
                        // Get the WiFi IP Address
                        IPAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)Temp->ifa_addr)->sin_addr)];
                    }
                }
                
                // Set the temp value to the next interface
                Temp = Temp->ifa_next;
            }
        }
        
        // Free the memory of the interfaces
        freeifaddrs(Interfaces);
        
        // Check to make sure it's not empty
        if (IPAddress == nil || IPAddress.length <= 0) {
            // Empty, return not found
            return nil;
        }
        
        // Return the IP Address of the WiFi
        return IPAddress;
    }
    @catch (NSException *exception) {
        // Error, IP Not found
        return nil;
    }
}

// Carrier Name
+ (NSString *)carrierName {
    // Get the carrier name
    @try {
        // Get the Telephony Network Info
        CTTelephonyNetworkInfo *TelephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
        // Get the carrier
        CTCarrier *Carrier = [TelephonyInfo subscriberCellularProvider];
        // Get the carrier name
        NSString *CarrierName = [Carrier carrierName];
        
        // Check to make sure it's valid
        if (CarrierName == nil || CarrierName.length <= 0) {
            // Return unknown
            return @"Unknown";
        }
        
        // Return the name
        return CarrierName;
    }
    @catch (NSException *exception) {
        // Error finding the name
        return nil;
    }
}

+ (NSInteger)getNetworkId
{
    if([PYAdUtility connectedToWiFi])
    {
        return 0;
    }
    else
    {
        NSString *string = [PYAdUtility carrierName];
        
        if(string != nil)
        {
            if([string isEqualToString:@"中国移动"])
            {
                return 70120;
            }
            else if([string isEqualToString:@"中国电信"])
            {
                return 70121;
            }
            else if([string isEqualToString:@"中国联通"])
            {
                return 70123;
            }
        }
        return 0;
    }
}

// Connected to Cellular Network?
+ (BOOL)connectedToCellNetwork {
    // Check if we're connected to cell network
    NSString *CellAddress = [PYAdUtility cellIPAddress];
    // Check if the string is populated
    if (CellAddress == nil || CellAddress.length <= 0) {
        // Nothing found
        return false;
    } else {
        // Cellular Network in use
        return true;
    }
}

+ (NSString *)dataNetworkTypeFromStatusBar {
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSNumber *dataNetworkItemView = nil;
    
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    
    NSString *netType = @"None";
    NSNumber * num = [dataNetworkItemView valueForKey:@"dataNetworkType"];
    if (num == nil) {
        
        netType = @"None";
        
    }else{
        
        int n = [num intValue];
        if (n == 0) {
            netType = @"None";
        }else if (n == 1){
            netType = @"2G";
        }else if (n == 2){
            netType = @"3G";
        }else{
            netType = @"Wifi";
        }
        
    }
    
    return netType;
}

// Get Cell IP Address
+ (NSString *)cellIPAddress {
    // Get the Cell IP Address
    @try {
        // Set a string for the address
        NSString *IPAddress = nil;
        // Set up structs to hold the interfaces and the temporary address
        struct ifaddrs *Interfaces;
        struct ifaddrs *Temp;
        struct sockaddr_in *s4;
        char buf[64];
        
        // If it's 0, then it's good
        if (!getifaddrs(&Interfaces))
        {
            // Loop through the list of interfaces
            Temp = Interfaces;
            
            // Run through it while it's still available
            while(Temp != NULL)
            {
                // If the temp interface is a valid interface
                if(Temp->ifa_addr->sa_family == AF_INET)
                {
                    // Check if the interface is Cell
                    if([[NSString stringWithUTF8String:Temp->ifa_name] isEqualToString:@"pdp_ip0"])
                    {
                        s4 = (struct sockaddr_in *)Temp->ifa_addr;
                        
                        if (inet_ntop(Temp->ifa_addr->sa_family, (void *)&(s4->sin_addr), buf, sizeof(buf)) == NULL) {
                            // Failed to find it
                            IPAddress = nil;
                        } else {
                            // Got the Cell IP Address
                            IPAddress = [NSString stringWithUTF8String:buf];
                        }
                    }
                }
                
                // Set the temp value to the next interface
                Temp = Temp->ifa_next;
            }
        }
        
        // Free the memory of the interfaces
        freeifaddrs(Interfaces);
        
        // Check to make sure it's not empty
        if (IPAddress == nil || IPAddress.length <= 0) {
            // Empty, return not found
            return nil;
        }
        
        // Return the IP Address of the WiFi
        return IPAddress;
    }
    @catch (NSException *exception) {
        // Error, IP Not found
        return nil;
    }
}

// Get Current IP Address
+ (NSString *)currentIPAddress {
    // Get the current IP Address
    
    // Check which interface is currently in use
    if ([PYAdUtility connectedToWiFi]) {
        // WiFi is in use
        
        // Get the WiFi IP Address
        NSString *WiFiAddress = [PYAdUtility wiFiIPAddress];
        
        // Check that you get something back
        if (WiFiAddress == nil || WiFiAddress.length <= 0) {
            // Error, no address found
            return nil;
        }
        
        // Return Wifi address
        return WiFiAddress;
    } else if ([PYAdUtility connectedToCellNetwork]) {
        // Cell Network is in use
        
        // Get the Cell IP Address
        NSString *CellAddress = [PYAdUtility cellIPAddress];
        
        // Check that you get something back
        if (CellAddress == nil || CellAddress.length <= 0) {
            // Error, no address found
            return nil;
        }
        
        // Return Cell address
        return CellAddress;
    } else {
        // No interface in use
        return nil;
    }
}

+ (NSString *)getCurrentIPAddress
{
    NSString *string = [PYAdUtility currentIPAddress];
    if(string && ![string isEqualToString:@""])
    {
        return string;
    }
    else
    {
        return @"0.0.0.0";
    }
}

+ (NSInteger)getMinuteFromGMT
{
    NSInteger minuteFromGMT = [[NSTimeZone localTimeZone] secondsFromGMT] / 60;
    
    return minuteFromGMT;
}

+ (NSString *)getAppName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

+ (NSString *)getAppVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

+ (NSDictionary *)getBannerTestBigRequestDictionaryWithAdUnitId:(NSString *)adUnitId
                                                     adUnitSize:(CGSize)adUnitSize
{
    NSDictionary *dictionary = [PYAdUtility getBigRequestDictionaryWithTestFlag:NO
                                                                       pingFlag:NO
                                                                 fullScreenFlag:NO
                                                                      supportJS:NO
                                                                         userId:@""
                                                                  cookieVersion:0
                                                               cookieAgeSeconds:0
                                                                       adUnitId:adUnitId
                                                                     adUnitSize:adUnitSize
                                                                    maxDuration:0
                                                                    minDuration:0
                                                                     adUnitType:@"BANNER"
                                                                 adUnitLocation:@""
                                                                adUnitLinearity:@""];
    
    return dictionary;
}

+ (NSMutableDictionary *)getDeviceInfoDictionary
{
    //device	required	device	设备描述信息。
    NSMutableDictionary *device = [NSMutableDictionary dictionaryWithCapacity:0];
    //os            required	string      操作系统名称，例如：Android。
    [device setObject:[PYAdUtility getOsAndVersion] forKey:@"os"];
    //device_type	required	enum        设备类型。详见DeviceType描述。
    [device setObject:@"Mobile" forKey:@"dt"];
    [device setObject:@"iPhone" forKey:@"db"];
    //model         optional	string      设备型号，例如：GT-I9500。
    [device setObject:[PYAdUtility getDeviceModelName] forKey:@"dm"];
    [device setObject:[PYAdUtility getDeviceIDFA] forKey:@"ia"];
    [device setObject:@"" forKey:@"ud"];
    //mac           optional	string      Wifi或者蓝牙的MAC地址。
    [device setObject:[PYAdUtility getMacAddress] forKey:@"wm"];
    // 运营商
    [device setObject:[NSNumber numberWithInteger:[PYAdUtility getNetworkId]] forKey:@"mc"];
    // net 网络制式，2G，3G，4G
    [device setObject:[PYAdUtility dataNetworkTypeFromStatusBar] forKey:@"net"];
    
    [device setObject:[PYAdUtility getSystemLanguage] forKey:@"lan"];
    //timezone_offset	optional	integer 	时区的分钟偏移值，例如东八区(GMT+8)的时区偏移值为:480
    [device setObject:[NSNumber numberWithInteger:[PYAdUtility getMinuteFromGMT]] forKey:@"tz"];
    // screen width and height
    [device setObject:[NSNumber numberWithInteger:[PYAdUtility getScreenWidth]] forKey:@"rew"];
    [device setObject:[NSNumber numberWithInteger:[PYAdUtility getScreenHeight]] forKey:@"reh"];
    
    return device;
}



+ (NSDictionary *)getBigRequestDictionaryWithTestFlag:(BOOL)isTest
                                             pingFlag:(BOOL)isPing
                                       fullScreenFlag:(BOOL)fullScreenFlag
                                            supportJS:(BOOL)supportJS
                                               userId:(NSString *)userId
                                        cookieVersion:(NSInteger)cookieVersion
                                     cookieAgeSeconds:(NSInteger)cookieAgeSeconds
                                             adUnitId:(NSString *)adUnitId
                                           adUnitSize:(CGSize)adUnitSize
                                          maxDuration:(NSInteger)maxDuration
                                          minDuration:(NSInteger)minDuration
                                           adUnitType:(NSString *)adUnitType
                                       adUnitLocation:(NSString *)adUnitLocation
                                      adUnitLinearity:(NSString *)adUnitLinearity
{
    NSMutableDictionary *bigRequestDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    
    //id        required	string	唯一标识一次广告请求。
    NSString *adId = [NSString stringWithFormat:@"%i_%i", (int)[[NSDate date] timeIntervalSince1970],rand()];
    [bigRequestDictionary setObject:adId forKey:@"id"];
    //is_test	optional	bool	是否是测试请求，投放系统仍会对测试请求进行响应，但是内部处理方式会特别标识。
    [bigRequestDictionary setObject:[NSNumber numberWithBool:isTest] forKey:@"is_test"];
    //is_ping	optional	bool	是否是心跳请求，投放系统不会对心跳请求进行处理，直接返回http status 204。
    [bigRequestDictionary setObject:[NSNumber numberWithBool:isPing] forKey:@"is_ping"];
    //device	required	device	设备描述信息。
    NSMutableDictionary *device = [NSMutableDictionary dictionaryWithCapacity:0];

        //os            required	string      操作系统名称，例如：Android。
        [device setObject:[PYAdUtility getSystemName] forKey:@"os"];
        //os_version	optional	osversion	操作系统版本号。详见OsVersion描述。
        [device setObject:[PYAdUtility getSystemVersion] forKey:@"os_version"];
        //brand         optional	string      设备品牌，例如：Samsung。
        
        //model         optional	string      设备型号，例如：GT-I9500。
        [device setObject:[PYAdUtility getDeviceModelName] forKey:@"brand"];
        //user_agent	optional	string      浏览器的UA信息。
        [device setObject:[PYAdUtility getUserAgent] forKey:@"user_agent"];
        //network_id	optional	integer 	用户的上网类型，例如使用Wifi上网或者使用中国联通3G服务上网。
        [device setObject:[NSNumber numberWithInteger:[PYAdUtility getNetworkId]] forKey:@"network_id"];
        //detected_language         optional	string	设备语言。推荐使用alpha-2/ISO 639-1规范的语言编码和ISO_3166规范的国家编码进行组合表示，中间以下划线分隔。例如简体中文表示为“zh_CN”。
        [device setObject:[PYAdUtility getSystemLanguage] forKey:@"detected_language"];
        //device_type	required	enum        设备类型。详见DeviceType描述。
        [device setObject:@"MOBILE" forKey:@"device_type"];
        //screen_width	optional	integer 	屏幕宽度，单位是像素。
        [device setObject:[NSNumber numberWithInteger:[PYAdUtility getScreenWidth]] forKey:@"screen_width"];
        //screen_height	optional	integer 	屏幕高度，单位是像素。
        [device setObject:[NSNumber numberWithInteger:[PYAdUtility getScreenHeight]] forKey:@"screen_height"];
        //screen_orientation        optional	enum	屏幕方向。详见ScreenOrientation描述。
        [device setObject:[PYAdUtility getScreenOrientation] forKey:@"screen_orientation"];
        //is_interstitial_request	optional	bool	是否是全屏广告请求。True表示是，false表示不是。
        [device setObject:[NSNumber numberWithBool:fullScreenFlag] forKey:@"is_interstitial_request"];
        //idfa          optional	string      iOS或者Android设备的IDFA。
        [device setObject:[PYAdUtility getDeviceIDFA] forKey:@"idfa"];
        //idfa_enc      optional	enum        IDFA的摘要方法。详见DigestType描述。
        
        //udid          optional	string      iOS设备的UDID信息。详见DigestType描述。

        //udid_enc      optional	enum        UDID的摘要方法。详见DigestType描述。

        //android_id	optional	string      Android设备的ID。
        
        //device_id_enc	optional	enum        DeviceId的摘要方法。详见DigestType描述。
        
        //mac           optional	string      Wifi或者蓝牙的MAC地址。
        [device setObject:[PYAdUtility getMacAddress] forKey:@"mac"];
        //mac_enc       optional	enum        MAC地址的摘要方法。详见DigestType描述。
        
        //js_enabled	optional	bool        广告位是否支持JavaScript。
        [device setObject:[NSNumber numberWithBool:supportJS] forKey:@"js_enabled"];
    //wujun
    NSString *fp = [OpenFingerPrint getFp];
    if(fp!=nil){
        [device setObject:fp forKey:@"fp"];
    }
    [bigRequestDictionary setObject:device forKey:@"device"];
    //adunit	required	adunit	广告位描述信息。
    NSMutableDictionary *adUnitInfo = [NSMutableDictionary dictionaryWithCapacity:0];

        //id        required	string      广告位ID。
        [adUnitInfo setObject:adUnitId forKey:@"id"];
        //width     optional	integer 	广告位宽度。
        [adUnitInfo setObject:[NSNumber numberWithInt:adUnitSize.width] forKey:@"width"];
        //height	optional	integer 	广告位高度。
        [adUnitInfo setObject:[NSNumber numberWithInt:adUnitSize.height] forKey:@"height"];
        //max_duration	optional	integer 	对于视频广告创意，可接受的最多视频时长，单位是毫秒。小于等于0表示不限制。
        [adUnitInfo setObject:[NSNumber numberWithInteger:maxDuration] forKey:@"max_duration"];
        //min_duration	optional	integer 	对于视频广告创意，可接受的最短视频时长，单位是毫秒。小于等于0表示不限制。
        [adUnitInfo setObject:[NSNumber numberWithInteger:minDuration] forKey:@"min_duration"];
        //adunit_type	required	enum	广告位类型。详见AdUnitType描述。
        [adUnitInfo setObject:adUnitType forKey:@"adunit_type"];
        //ad_location	optional	enum	广告位置。详见AdLocation描述。
        [adUnitInfo setObject:adUnitLocation forKey:@"ad_location"];
        //linearity     optional	enum	广告展现形式。详见Linearity描述。
        [adUnitInfo setObject:adUnitLinearity forKey:@"linearity"];
    
    [bigRequestDictionary setObject:adUnitInfo forKey:@"adunit"];
    //geo       required	geo     地理信息。
    NSMutableDictionary *geoInfo = [NSMutableDictionary dictionaryWithCapacity:0];

        //ip            requird     string	用点分十进制表示的IPV4地址。
        [geoInfo setObject:[PYAdUtility getCurrentIPAddress] forKey:@"ip"];
        //postal_code	optional	string	邮政编码。
        
        //timezone_offset	optional	integer 	时区的分钟偏移值，例如东八区(GMT+8)的时区偏移值为:480
        [geoInfo setObject:[NSNumber numberWithInteger:[PYAdUtility getMinuteFromGMT]] forKey:@"timezone_offset"];
        //latitude      optional	float	纬度。
        
        //longtitude	optional	float	经度。
    
    [bigRequestDictionary setObject:geoInfo forKey:@"geo"];
    //app       optional	app     本地应用信息。
    NSMutableDictionary *appInfo = [NSMutableDictionary dictionaryWithCapacity:0];

        //id        required	string          应用程序ID，Android上表现为程序的包名,例如：com.rovio.angrybirds，iOS上表现为AppStore上的ID，例如：357890。
        [appInfo setObject:[NSNumber numberWithInteger:[[PYAppManager defaultManager] trackId]] forKey:@"id"];
        //cats      optional	array of string	应用在AppStore或者GooglePlay或者其他应用市场的的分类信息。
        
        //name      optional	string          应用程序名称。
        [appInfo setObject:[PYAdUtility getAppName] forKey:@"name"];
        //version	optional	string          应用程序版本。
        [appInfo setObject:[PYAdUtility getAppVersion] forKey:@"version"];
        //is_paid	optional	bool            应用是否收费。
        [appInfo setObject:[NSNumber numberWithBool:([[PYAppManager defaultManager] price] > 0 ? YES : NO)] forKey:@"is_paid"];
    [bigRequestDictionary setObject:appInfo forKey:@"app"];
    //site      optional	site	站点信息。
    NSMutableDictionary *siteInfo = [NSMutableDictionary dictionaryWithCapacity:0];

        //page      required	string	当前页面的URL。
        
        //name      optional	string	当前站点的名称。
        
        //referrer	optional	string	当前页面的前导URL。
    
    [bigRequestDictionary setObject:siteInfo forKey:@"site"];
    //user_id	optional	string	访客的ID。
    [bigRequestDictionary setObject:userId forKey:@"user_id"];
    //cookie_version        optional	integer	Cookie版本。
    [bigRequestDictionary setObject:[NSNumber numberWithInteger:cookieVersion] forKey:@"cookie_version"];
    //cookie_age_seconds	optional	integer	从user_id生成到现在经过的秒数。
    [bigRequestDictionary setObject:[NSNumber numberWithInteger:cookieAgeSeconds] forKey:@"cookie_age_seconds"];
    
    return bigRequestDictionary;
}

//序列化写入缓存
+ (void)archiveData:(NSArray *)array IntoCache:(NSString *)path
{
    if (!path || ![path length]) {
        return;
    }
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *myPath    = [myPathList  objectAtIndex:0];
    //创建子目录
    BOOL isDir = NO;
    NSString *taskPath = [NSString stringWithFormat:@"%@/pyad",myPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:taskPath isDirectory:(&isDir)]) {
        [fileManager createDirectoryAtPath:taskPath withIntermediateDirectories:NO attributes:nil error:nil];
        isDir = YES;
    }
    //创建文件目录
    //    myPath = [myPath stringByAppendingPathComponent:path];
    myPath = [taskPath stringByAppendingPathComponent:path];

//    if(![[NSFileManager defaultManager] fileExistsAtPath:myPath])
//    {
//        NSFileManager *fileManager = [NSFileManager defaultManager ];
//        [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
//        [[NSFileManager defaultManager] createFileAtPath:myPath contents:nil attributes:nil];
//    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    
    dispatch_queue_t queue = dispatch_queue_create("com.ipinyou.archive", NULL);
    dispatch_sync(queue, ^{
        if(![data writeToFile:myPath atomically:YES])
        {
            
        }
    });
}

+ (NSArray *)unarchiveDataFromCache:(NSString *)path
{
    if (!path || ![path length]) {
        return nil;
    }
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *myPath    = [myPathList  objectAtIndex:0];
    NSData *fData       = nil;
    //创建子目录
    BOOL isDir = NO;
    NSString *taskPath = [NSString stringWithFormat:@"%@/pyad",myPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:taskPath isDirectory:(&isDir)]) {
        [fileManager createDirectoryAtPath:taskPath withIntermediateDirectories:NO attributes:nil error:nil];
        isDir = YES;
    }
    //创建文件目录
    //    myPath = [myPath stringByAppendingPathComponent:path];
    myPath = [taskPath stringByAppendingPathComponent:path];

    if([[NSFileManager defaultManager] fileExistsAtPath:myPath])
    {
        fData = [NSData dataWithContentsOfFile:myPath];
    }
    if (fData == nil ) {
        return nil;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithData:fData];
}

+ (void)getAppList:(AdUtilityAppBlock)appBlock
           failure:(AdUtilityFailureBlock)failureBlock
{
	appBlock([[NSArray alloc] init]);
//    iHasApp *hasAppObject = [[[iHasApp alloc] init] autorelease];
//
//    [hasAppObject detectAppIdsWithIncremental:^(NSArray *appIds) {
//
//    } withSuccess:^(NSArray *appIds) {
////        NSLog(@"%@", [appIds description]);
//        if(appBlock != nil)
//        {
//            appBlock(appIds);
//        }
//    } withFailure:^(NSError *error) {
//        if(failureBlock)
//        {
//            failureBlock(error);
//        }
//    }];
}

@end
