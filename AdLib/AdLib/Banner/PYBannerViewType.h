//
//  PYBannerViewType.h
//  AdLib
//
//  Created by lide on 14-3-17.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _BannerViewType
{
    BannerViewTop = 0,
    BannerViewBottom = 1,
    BannerViewAny = 2,
    BannerViewPreload = 3,
}BannerViewType;

@interface PYBannerView ()

- (BannerViewType)type;
- (void)setBannerType:(BannerViewType)type;

@end