//
//  PYModel.h
//  AdLib
//
//  Created by lide on 14-2-19.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PYModel : NSObject <NSCoding, NSCopying>
{
    NSString        *_mimeType;
    NSNumber        *_maxCPM;
    NSString        *_currency;
    NSString        *_modelId;
    NSString        *_adUnitId;
    NSString        *_imageURL;
    NSString        *_width;
    NSString        *_height;
//    NSString        *_openURL;
//    NSString        *_trackURL;
    NSArray         *_openURLArray;
    NSArray         *_trackURLArray;
    NSString        *_htmlSnippet;
    NSData          *_modelData;
}

@property (retain, nonatomic) NSString *mimeType;
@property (retain, nonatomic) NSNumber *maxCPM;
@property (retain, nonatomic) NSString *currency;
@property (retain, nonatomic) NSString *modelId;
@property (retain, nonatomic) NSString *adUnitId;
@property (retain, nonatomic) NSString *imageURL;
@property (retain, nonatomic) NSString *width;
@property (retain, nonatomic) NSString *height;
//@property (retain, nonatomic) NSString *openURL;
//@property (retain, nonatomic) NSString *trackURL;
@property (retain, nonatomic) NSArray *openURLArray;
@property (retain, nonatomic) NSArray *trackURLArray;
@property (retain, nonatomic) NSString *htmlSnippet;
@property (retain, nonatomic) NSData *modelData;

- (id)initWithAttribute:(NSDictionary *)attribute;

@end