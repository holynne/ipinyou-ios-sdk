//
//  PYModel.m
//  AdLib
//
//  Created by lide on 14-2-19.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import "PYModel.h"
#import "PYAdUtility.h"
#import "PYModelRequest.h"

@implementation PYModel

@synthesize mimeType = _mimeType;
@synthesize maxCPM = _maxCPM;
@synthesize currency = _currency;
@synthesize modelId = _modelId;
@synthesize adUnitId = _adUnitId;
@synthesize imageURL = _imageURL;
@synthesize width = _width;
@synthesize height = _height;
//@synthesize openURL = _openURL;
//@synthesize trackURL = _trackURL;
@synthesize openURLArray = _openURLArray;
@synthesize trackURLArray = _trackURLArray;
@synthesize htmlSnippet = _htmlSnippet;
@synthesize modelData = _modelData;

- (id)copyWithZone:(NSZone *)zone
{
    PYModel *model = [[[self class] allocWithZone:zone] init];
    
    model.mimeType = _mimeType;
    model.maxCPM = _maxCPM;
    model.currency = _currency;
    model.modelId = _modelId;
    model.adUnitId = _adUnitId;
    model.imageURL = _imageURL;
//    model.openURL = _openURL;
//    model.trackURL = _trackURL;
    model.openURLArray = _openURLArray;
    model.trackURLArray = _trackURLArray;
    model.htmlSnippet = _htmlSnippet;
    model.modelData = _modelData;
    
    return model;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_mimeType forKey:@"mimeType"];
    [aCoder encodeObject:_maxCPM forKey:@"maxCPM"];
    [aCoder encodeObject:_currency forKey:@"currency"];
    [aCoder encodeObject:_modelId forKey:@"modelId"];
    [aCoder encodeObject:_adUnitId forKey:@"adUnitId"];
    [aCoder encodeObject:_imageURL forKey:@"imageURL"];
//    [aCoder encodeObject:_openURL forKey:@"openURL"];
//    [aCoder encodeObject:_trackURL forKey:@"trackURL"];
    [aCoder encodeObject:_openURLArray forKey:@"openURLArray"];
    [aCoder encodeObject:_trackURLArray forKey:@"trackURLArray"];
    [aCoder encodeObject:_htmlSnippet forKey:@"htmlSnippet"];
    [aCoder encodeObject:_modelData forKey:@"modelData"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.mimeType = [aDecoder decodeObjectForKey:@"mimeType"];
        self.maxCPM = [aDecoder decodeObjectForKey:@"maxCPM"];
        self.currency = [aDecoder decodeObjectForKey:@"currency"];
        self.modelId = [aDecoder decodeObjectForKey:@"modelId"];
        self.adUnitId = [aDecoder decodeObjectForKey:@"adUnitId"];
        self.imageURL = [aDecoder decodeObjectForKey:@"imageURL"];
//        self.openURL = [aDecoder decodeObjectForKey:@"openURL"];
//        self.trackURL = [aDecoder decodeObjectForKey:@"trackURL"];
        self.openURLArray = [aDecoder decodeObjectForKey:@"openURLArray"];
        self.trackURLArray = [aDecoder decodeObjectForKey:@"trackURLArray"];
        self.htmlSnippet = [aDecoder decodeObjectForKey:@"htmlSnippet"];
        self.modelData = [aDecoder decodeObjectForKey:@"modelData"];
    }
    
    return self;
}

- (id)initWithAttribute:(NSDictionary *)attribute
{
    self = [super init];
    if(self != nil)
    {
        if(attribute != nil)
        {
            if(![[attribute objectForKey:@"mime"] isEqual:[NSNull null]])
            {
                self.mimeType = [attribute objectForKey:@"mime"];
            }
            
            if([self.mimeType isEqualToString:@"application/rss+xml"])
            {
                if(![[attribute objectForKey:@"max_cpm"] isEqual:[NSNull null]])
                {
                    self.maxCPM = [NSNumber numberWithInteger:[[attribute objectForKey:@"max_cpm"] integerValue]];
                }
                if(![[attribute objectForKey:@"currency"] isEqual:[NSNull null]])
                {
                    self.currency = [attribute objectForKey:@"currency"];
                }
                if(![[attribute objectForKey:@"id"] isEqual:[NSNull null]])
                {
                    self.modelId = [attribute objectForKey:@"id"];
                }
                if(![[attribute objectForKey:@"adunit_id"] isEqual:[NSNull null]])
                {
                    self.adUnitId = [attribute objectForKey:@"adunit_id"];
                }
                if(![[attribute objectForKey:@"width"] isEqual:[NSNull null]])
                {
                    self.width = [attribute objectForKey:@"width"];
                }
                if(![[attribute objectForKey:@"height"] isEqual:[NSNull null]] )
                {
                    self.height = [attribute objectForKey:@"height"];
                }
                if(![[attribute objectForKey:@"html_snippet"] isEqual:[NSNull null]])
                {
                    NSString *htmlSnippet = [attribute objectForKey:@"html_snippet"];
                    NSData *data = [htmlSnippet dataUsingEncoding:NSUTF8StringEncoding];
                    id dic = [PYAdUtility dictionaryWithJSONData:data];
                    if([dic isKindOfClass:[NSDictionary class]])
                    {
                        self.imageURL = [dic objectForKey:@"url"];
                    }
                }
                if(![[attribute objectForKey:@"click_through_urls"] isEqual:[NSNull null]])
                {
                    NSArray *clickThroughURLArray = [attribute objectForKey:@"click_through_urls"];
                    if(clickThroughURLArray && [clickThroughURLArray isKindOfClass:[NSArray class]] && [clickThroughURLArray count] > 0)
                    {
                        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:0];
                        for(NSString *clickThroughURL in clickThroughURLArray)
                        {
                            if([clickThroughURL rangeOfString:@"%%WINNING_PRICE%%"].location != NSNotFound)
                            {
                                clickThroughURL = [clickThroughURL stringByReplacingOccurrencesOfString:@"%%WINNING_PRICE%%" withString:[self.maxCPM stringValue]];
                            }
                            if([clickThroughURL rangeOfString:@"%%WINNING_CURRENCY%%"].location != NSNotFound)
                            {
                                clickThroughURL = [clickThroughURL stringByReplacingOccurrencesOfString:@"%%WINNING_CURRENCY%%" withString:self.currency];
                            }
                            if([clickThroughURL rangeOfString:@"%%CLICK_URL_UNESC%%"].location != NSNotFound)
                            {
                                clickThroughURL = [clickThroughURL stringByReplacingOccurrencesOfString:@"%%CLICK_URL_UNESC%%" withString:@""];
                            }
                            if([clickThroughURL rangeOfString:@"%%CLICK_URL_ESC%%"].location != NSNotFound)
                            {
                                clickThroughURL = [clickThroughURL stringByReplacingOccurrencesOfString:@"%%CLICK_URL_ESC%%" withString:@""];
                            }
                            if([clickThroughURL rangeOfString:@"%%CLICK_URL_ESC_ESC%%"].location != NSNotFound)
                            {
                                clickThroughURL = [clickThroughURL stringByReplacingOccurrencesOfString:@"%%CLICK_URL_ESC_ESC%%" withString:@""];
                            }
//                            if([clickThroughURL rangeOfString:@"%%TIMESTAMP%%"].location != NSNotFound)
//                            {
//                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                                [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
//                                NSString *string = [dateFormatter stringFromDate:[NSDate date]];
//                                
//                                clickThroughURL = [clickThroughURL stringByReplacingOccurrencesOfString:@"%%TIMESTAMP%%" withString:string];
//                                [dateFormatter release];
//                            }
                            
                            PYModelRequest *request = [[[PYModelRequest alloc] init] autorelease];
                            request.requestURLString = [clickThroughURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            [mutableArray addObject:request];
                        }
                        self.openURLArray = mutableArray;
                        [mutableArray release];
                    }
                }
                if(![[attribute objectForKey:@"tracking_urls"] isEqual:[NSNull null]])
                {
                    NSArray *trackingURLArray = [attribute objectForKey:@"tracking_urls"];
                    if(trackingURLArray && [trackingURLArray isKindOfClass:[NSArray class]] && [trackingURLArray count] > 0)
                    {
                        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:0];
                        for(NSString *trackingURLString in trackingURLArray)
                        {
                            if([trackingURLString rangeOfString:@"%%WINNING_PRICE%%"].location != NSNotFound)
                            {
                                trackingURLString = [trackingURLString stringByReplacingOccurrencesOfString:@"%%WINNING_PRICE%%" withString:[self.maxCPM stringValue]];
                            }
                            if([trackingURLString rangeOfString:@"%%WINNING_CURRENCY%%"].location != NSNotFound)
                            {
                                trackingURLString = [trackingURLString stringByReplacingOccurrencesOfString:@"%%WINNING_CURRENCY%%" withString:self.currency];
                            }
                            if([trackingURLString rangeOfString:@"%%CLICK_URL_UNESC%%"].location != NSNotFound)
                            {
                                trackingURLString = [trackingURLString stringByReplacingOccurrencesOfString:@"%%CLICK_URL_UNESC%%" withString:@""];
                            }
                            if([trackingURLString rangeOfString:@"%%CLICK_URL_ESC%%"].location != NSNotFound)
                            {
                                trackingURLString = [trackingURLString stringByReplacingOccurrencesOfString:@"%%CLICK_URL_ESC%%" withString:@""];
                            }
                            if([trackingURLString rangeOfString:@"%%CLICK_URL_ESC_ESC%%"].location != NSNotFound)
                            {
                                trackingURLString = [trackingURLString stringByReplacingOccurrencesOfString:@"%%CLICK_URL_ESC_ESC%%" withString:@""];
                            }
//                            if([trackingURLString rangeOfString:@"%%TIMESTAMP%%"].location != NSNotFound)
//                            {
//                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                                [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
//                                NSString *string = [dateFormatter stringFromDate:[NSDate date]];
//                                
//                                trackingURLString = [trackingURLString stringByReplacingOccurrencesOfString:@"%%TIMESTAMP%%" withString:string];
//                                [dateFormatter release];
//                            }
                            
                            PYModelRequest *request = [[[PYModelRequest alloc] init] autorelease];
                            request.requestURLString = [trackingURLString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            [mutableArray addObject:request];
                        }
                        self.trackURLArray = mutableArray;
                        [mutableArray release];
                    }
                }
            }
            else
            {
                if(![[attribute objectForKey:@"max_cpm"] isEqual:[NSNull null]])
                {
                    self.maxCPM = [NSNumber numberWithInteger:[[attribute objectForKey:@"max_cpm"] integerValue]];
                }
                if(![[attribute objectForKey:@"currency"] isEqual:[NSNull null]])
                {
                    self.currency = [attribute objectForKey:@"currency"];
                }
                if(![[attribute objectForKey:@"id"] isEqual:[NSNull null]])
                {
                    self.modelId = [attribute objectForKey:@"id"];
                }
                if(![[attribute objectForKey:@"adunit_id"] isEqual:[NSNull null]])
                {
                    self.adUnitId = [attribute objectForKey:@"adunit_id"];
                }
                if(![[attribute objectForKey:@"html_snippet"] isEqual:[NSNull null]])
                {
                    self.htmlSnippet = [attribute objectForKey:@"html_snippet"];
                }
                if(![[attribute objectForKey:@"width"] isEqual:[NSNull null]])
                {
                    self.width = [attribute objectForKey:@"width"];
                }
                if(![[attribute objectForKey:@"height"] isEqual:[NSNull null]] )
                {
                    self.height = [attribute objectForKey:@"height"];
                }
                
                if(![[attribute objectForKey:@"click_through_urls"] isEqual:[NSNull null]])
                {
                    NSArray *clickThroughURLArray = [attribute objectForKey:@"click_through_urls"];
                    if(clickThroughURLArray && [clickThroughURLArray isKindOfClass:[NSArray class]] && [clickThroughURLArray count] > 0)
                    {
                        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:0];
                        for(NSString *clickThroughURL in clickThroughURLArray)
                        {
                            if([clickThroughURL rangeOfString:@"%%WINNING_PRICE%%"].location != NSNotFound)
                            {
                                clickThroughURL = [clickThroughURL stringByReplacingOccurrencesOfString:@"%%WINNING_PRICE%%" withString:[self.maxCPM stringValue]];
                            }
                            if([clickThroughURL rangeOfString:@"%%WINNING_CURRENCY%%"].location != NSNotFound)
                            {
                                clickThroughURL = [clickThroughURL stringByReplacingOccurrencesOfString:@"%%WINNING_CURRENCY%%" withString:self.currency];
                            }
                            if([clickThroughURL rangeOfString:@"%%CLICK_URL_UNESC%%"].location != NSNotFound)
                            {
                                clickThroughURL = [clickThroughURL stringByReplacingOccurrencesOfString:@"%%CLICK_URL_UNESC%%" withString:@""];
                            }
                            if([clickThroughURL rangeOfString:@"%%CLICK_URL_ESC%%"].location != NSNotFound)
                            {
                                clickThroughURL = [clickThroughURL stringByReplacingOccurrencesOfString:@"%%CLICK_URL_ESC%%" withString:@""];
                            }
                            if([clickThroughURL rangeOfString:@"%%CLICK_URL_ESC_ESC%%"].location != NSNotFound)
                            {
                                clickThroughURL = [clickThroughURL stringByReplacingOccurrencesOfString:@"%%CLICK_URL_ESC_ESC%%" withString:@""];
                            }
//                            if([clickThroughURL rangeOfString:@"%%TIMESTAMP%%"].location != NSNotFound)
//                            {
//                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                                [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
//                                NSString *string = [dateFormatter stringFromDate:[NSDate date]];
//                                
//                                clickThroughURL = [clickThroughURL stringByReplacingOccurrencesOfString:@"%%TIMESTAMP%%" withString:string];
//                                [dateFormatter release];
//                            }
                            
                            PYModelRequest *request = [[[PYModelRequest alloc] init] autorelease];
                            request.requestURLString = [clickThroughURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            [mutableArray addObject:request];
                        }
                        self.openURLArray = mutableArray;
                        [mutableArray release];
                    }
                }
                if(![[attribute objectForKey:@"tracking_urls"] isEqual:[NSNull null]])
                {
                    NSArray *trackingURLArray = [attribute objectForKey:@"tracking_urls"];
                    if(trackingURLArray && [trackingURLArray isKindOfClass:[NSArray class]] && [trackingURLArray count] > 0)
                    {
                        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:0];
                        for(NSString *trackingURLString in trackingURLArray)
                        {
                            if([trackingURLString rangeOfString:@"%%WINNING_PRICE%%"].location != NSNotFound)
                            {
                                trackingURLString = [trackingURLString stringByReplacingOccurrencesOfString:@"%%WINNING_PRICE%%" withString:[self.maxCPM stringValue]];
                            }
                            if([trackingURLString rangeOfString:@"%%WINNING_CURRENCY%%"].location != NSNotFound)
                            {
                                trackingURLString = [trackingURLString stringByReplacingOccurrencesOfString:@"%%WINNING_CURRENCY%%" withString:self.currency];
                            }
                            if([trackingURLString rangeOfString:@"%%CLICK_URL_UNESC%%"].location != NSNotFound)
                            {
                                trackingURLString = [trackingURLString stringByReplacingOccurrencesOfString:@"%%CLICK_URL_UNESC%%" withString:@""];
                            }
                            if([trackingURLString rangeOfString:@"%%CLICK_URL_ESC%%"].location != NSNotFound)
                            {
                                trackingURLString = [trackingURLString stringByReplacingOccurrencesOfString:@"%%CLICK_URL_ESC%%" withString:@""];
                            }
                            if([trackingURLString rangeOfString:@"%%CLICK_URL_ESC_ESC%%"].location != NSNotFound)
                            {
                                trackingURLString = [trackingURLString stringByReplacingOccurrencesOfString:@"%%CLICK_URL_ESC_ESC%%" withString:@""];
                            }
//                            if([trackingURLString rangeOfString:@"%%TIMESTAMP%%"].location != NSNotFound)
//                            {
//                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                                [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
//                                NSString *string = [dateFormatter stringFromDate:[NSDate date]];
//                                
//                                trackingURLString = [trackingURLString stringByReplacingOccurrencesOfString:@"%%TIMESTAMP%%" withString:string];
//                                [dateFormatter release];
//                            }
                            
                            PYModelRequest *request = [[[PYModelRequest alloc] init] autorelease];
                            request.requestURLString = [trackingURLString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            [mutableArray addObject:request];
                        }
                        self.trackURLArray = mutableArray;
                        [mutableArray release];
                    }
                }
            }
        }
    }
    
    return self;
}

- (void)dealloc
{
    PY_SAFE_RELEASE(_mimeType);
    PY_SAFE_RELEASE(_maxCPM);
    PY_SAFE_RELEASE(_currency);
    PY_SAFE_RELEASE(_modelId);
    PY_SAFE_RELEASE(_adUnitId);
    PY_SAFE_RELEASE(_imageURL);
    PY_SAFE_RELEASE(_openURLArray);
    PY_SAFE_RELEASE(_trackURLArray);
    PY_SAFE_RELEASE(_htmlSnippet);
    PY_SAFE_RELEASE(_modelData);
    
    [super dealloc];
}

@end
