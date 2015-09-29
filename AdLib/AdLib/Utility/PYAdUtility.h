//
//  AdUtility.h
//  AdLib
//
//  Created by lide on 14-2-18.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AdUtilitySuccessBlock)(id responseObject);
typedef void (^AdUtilityAppBlock)(NSArray *appIdArray);
typedef void (^AdUtilityFailureBlock)(NSError *error);

@interface PYAdUtility : NSObject

//JSON解析方法
+ (NSData *)JSONDataWithDictionary:(NSDictionary *)dictionary;
+ (id)dictionaryWithJSONData:(NSData *)data;

//从剪切板获取数据
+ (NSData *)dataFromPasteBoardWithType:(NSString *)type;
+ (void)setDataToPasteBoard:(NSData *)data type:(NSString *)type;

+ (NSDictionary *)getBannerTestBigRequestDictionaryWithAdUnitId:(NSString *)adUnitId
                                                     adUnitSize:(CGSize)adUnitSize;
+ (NSDictionary *)getDeviceInfoDictionary;
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
                                      adUnitLinearity:(NSString *)adUnitLinearity;

//序列化写入缓存
+ (void)archiveData:(NSArray *)array IntoCache:(NSString *)path;
+ (NSArray *)unarchiveDataFromCache:(NSString *)path;

+ (NSString *)getMacAddress;
+ (NSString *)getDeviceIDFA;
+ (BOOL)connectedToWiFi;
+ (NSString *)carrierName;

+ (void)getAppList:(AdUtilityAppBlock)appBlock
           failure:(AdUtilityFailureBlock)failureBlock;

@end
