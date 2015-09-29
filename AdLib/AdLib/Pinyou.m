//
//  AdLib.m
//  AdLib
//
//  Created by lide on 14-2-18.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import "Pinyou.h"
#import "PYAdUtility.h"
#import "PYModel.h"
#import "PYBannerView.h"
#import "PYBannerViewDelegate.h"
#import "PYAppManager.h"
#import "PYBannerViewType.h"
#import "PYOfflineSyncManager.h"
#import "PYInterstitialView.h"
#import "PYInterstitialViewDelegate.h"
#import "PYStartupView.h"
#import "PYStartupViewDelegate.h"
#import "PYAVPlayerView.h"

@interface Pinyou (PrivateMethod) <PYBannerViewDelegate,PYStartupViewDelegate,PYInterstitialViewDelegate>

+ (Pinyou *)defaultLibManager;

- (void)showAdViewWithFrame:(CGRect)rect
                  layerView:(UIView *)layerView
                   adUnitId:(NSString *)adUnitId;

- (void)showBannerViewFormTopWithSize:(CGSize)size
                             adUnitId:(NSString *)adUnitId;

- (void)showBannerViewFormBottomWithSize:(CGSize)size
                                adUnitId:(NSString *)adUnitId;

- (void)showInterstitialViewWithSize:(CGSize)size
                            adUnitId:(NSString *)adUnitId;

- (void)showDefaultTopBannerView;
- (void)showDefaultBottomBannerView;
- (void)showDefaultMiddleBannerView;

@end

@implementation Pinyou

#pragma mark - private

static id defaultLibManager = nil;
+ (Pinyou *)defaultLibManager
{
    @synchronized(defaultLibManager){
        if(defaultLibManager == nil)
        {
            defaultLibManager = [[Pinyou alloc] init];
        }
        
        [[PYAppManager defaultManager] getAppInfo];
        [[PYOfflineSyncManager defaultManager] prepareToSyncOfflineRequest];
    }
    return defaultLibManager;
}

- (id)init
{
    self = [super init];
    if(self != nil)
    {

    }
    
    return self;
}

- (void)showAdViewWithFrame:(CGRect)rect
                  layerView:(UIView *)layerView
                   adUnitId:(NSString *)adUnitId
{
    if(layerView == nil)
    {
        return;
    }
    
    PYBannerView *bannerView = [[[PYBannerView alloc] initWithFrame:rect] autorelease];
    bannerView.delegate = self;
    [bannerView setAdUnitId:adUnitId];
    [layerView addSubview:bannerView];
    
    [bannerView loadAdInfo];
}

- (void)showBannerViewFormTopWithSize:(CGSize)size
                             adUnitId:(NSString *)adUnitId
{
    id rootVC = [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] nextResponder];
    if(rootVC != nil)
    {
        PYBannerView *bannerView = [[[PYBannerView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)] autorelease];
        [bannerView setBannerType:BannerViewTop];
        bannerView.delegate = self;
        [bannerView setAdUnitId:adUnitId];
        if([rootVC isKindOfClass:[UINavigationController class]])
        {
            if([[[UIDevice currentDevice] systemVersion] floatValue] - 7 >= 0)
            {
                if([(UINavigationController *)rootVC isNavigationBarHidden] == NO)
                {
                    bannerView.frame = CGRectMake(0, [(UINavigationController *)rootVC navigationBar].frame.origin.y + [(UINavigationController *)rootVC navigationBar].frame.size.height, 320, 50);
                }
            }
            [[(UINavigationController *)rootVC visibleViewController].view addSubview:bannerView];
        }
        else if([rootVC isKindOfClass:[UITabBarController class]])
        {
            [[(UITabBarController *)rootVC selectedViewController].view addSubview:bannerView];
        }
        else
        {
            [[(UIViewController *)rootVC view] addSubview:bannerView];
        }
        
        [bannerView loadAdInfo];
    }
}

- (void)showBannerViewFormBottomWithSize:(CGSize)size
                                adUnitId:(NSString *)adUnitId
{
    id rootVC = [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] nextResponder];
    if(rootVC != nil)
    {
        CGSize rootSize = CGSizeZero;
        if([rootVC isKindOfClass:[UINavigationController class]])
        {
            rootSize = [(UINavigationController *)rootVC visibleViewController].view.frame.size;
        }
        else if([rootVC isKindOfClass:[UITabBarController class]])
        {
            rootSize = [(UITabBarController *)rootVC selectedViewController].view.frame.size;
        }
        else
        {
            rootSize = [(UIViewController *)rootVC view].frame.size;
        }
        PYBannerView *bannerView = [[[PYBannerView alloc] initWithFrame:CGRectMake(0, rootSize.height - size.height, size.width, size.height)] autorelease];
        [bannerView setBannerType:BannerViewBottom];
        bannerView.delegate = self;
        [bannerView setAdUnitId:adUnitId];
        if([rootVC isKindOfClass:[UINavigationController class]])
        {
            [[(UINavigationController *)rootVC visibleViewController].view addSubview:bannerView];
        }
        else if([rootVC isKindOfClass:[UITabBarController class]])
        {
            if([[[UIDevice currentDevice] systemVersion] floatValue] - 7 >= 0)
            {
                CGRect tabBarRect = [[(UITabBarController *)rootVC tabBar] frame];
                bannerView.frame = CGRectMake(0, bannerView.frame.origin.y - tabBarRect.size.height, bannerView.frame.size.width, bannerView.frame.size.height);
            }
            [[(UITabBarController *)rootVC selectedViewController].view addSubview:bannerView];
        }
        else
        {
            [[(UIViewController *)rootVC view] addSubview:bannerView];
        }
        
        [bannerView loadAdInfo];
    }
}

- (void)showInterstitialVideoWithAdUnitId:(NSString *)adUnitId
{
    PYAVPlayerView *playerView = [[PYAVPlayerView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)];
    [playerView loadAdInfo];
    [playerView release];
}

- (void)showInterstitialViewWithSize:(CGSize)size
                            adUnitId:(NSString *)adUnitId
{
    PYInterstitialView *interstitialView = [[[PYInterstitialView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)] autorelease];
    interstitialView.delegate = self;
    [interstitialView setAdUnitId:adUnitId];
    [interstitialView loadAdInfo];
}

- (void)showStartupViewWithSize:(CGSize)size adUnitId:(NSString *)adUnitId {
    PYStartupView *startupView = [[[PYStartupView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)] autorelease];
    startupView.delegate = self;
    [startupView setAdUnitId:adUnitId];
    [startupView loadAdInfo];
}

- (void)showDefaultTopBannerView
{
    id rootVC = [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] nextResponder];
    if(rootVC != nil)
    {
        PYBannerView *bannerView = [[[PYBannerView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)] autorelease];
        [bannerView setBannerType:BannerViewTop];
        bannerView.delegate = self;
        [bannerView setAdUnitId:@"hA.3Y"];
        if([rootVC isKindOfClass:[UINavigationController class]])
        {
            if([[[UIDevice currentDevice] systemVersion] floatValue] - 7 >= 0)
            {
                if([(UINavigationController *)rootVC isNavigationBarHidden] == NO)
                {
                    bannerView.frame = CGRectMake(0, [(UINavigationController *)rootVC navigationBar].frame.origin.y + [(UINavigationController *)rootVC navigationBar].frame.size.height, 320, 50);
                }
            }
            [[(UINavigationController *)rootVC visibleViewController].view addSubview:bannerView];
        }
        else if([rootVC isKindOfClass:[UITabBarController class]])
        {
            [[(UITabBarController *)rootVC selectedViewController].view addSubview:bannerView];
        }
        else
        {
            [[(UIViewController *)rootVC view] addSubview:bannerView];
        }
        
        [bannerView loadAdInfo];
    }
}

- (void)showDefaultBottomBannerView
{
    id rootVC = [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] nextResponder];
    if(rootVC != nil)
    {
        CGSize rootSize = CGSizeZero;
        if([rootVC isKindOfClass:[UINavigationController class]])
        {
            rootSize = [(UINavigationController *)rootVC visibleViewController].view.frame.size;
        }
        else if([rootVC isKindOfClass:[UITabBarController class]])
        {
            rootSize = [(UITabBarController *)rootVC selectedViewController].view.frame.size;
        }
        else
        {
            rootSize = [(UIViewController *)rootVC view].frame.size;
        }
        PYBannerView *bannerView = [[[PYBannerView alloc] initWithFrame:CGRectMake(0, rootSize.height - 50, 320, 50)] autorelease];
        [bannerView setBannerType:BannerViewBottom];
        bannerView.delegate = self;
        [bannerView setAdUnitId:@"_A.fo"];
        if([rootVC isKindOfClass:[UINavigationController class]])
        {
            [[(UINavigationController *)rootVC visibleViewController].view addSubview:bannerView];
        }
        else if([rootVC isKindOfClass:[UITabBarController class]])
        {
            if([[[UIDevice currentDevice] systemVersion] floatValue] - 7 >= 0)
            {
                CGRect tabBarRect = [[(UITabBarController *)rootVC tabBar] frame];
                bannerView.frame = CGRectMake(0, bannerView.frame.origin.y - tabBarRect.size.height, bannerView.frame.size.width, bannerView.frame.size.height);
            }
            [[(UITabBarController *)rootVC selectedViewController].view addSubview:bannerView];
        }
        else
        {
            [[(UIViewController *)rootVC view] addSubview:bannerView];
        }
        
        [bannerView loadAdInfo];
    }
}

- (void)showDefaultMiddleBannerView
{
    id rootVC = [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] nextResponder];
    if(rootVC != nil)
    {
        CGSize rootSize = CGSizeZero;
        if([rootVC isKindOfClass:[UINavigationController class]])
        {
            rootSize = [(UINavigationController *)rootVC visibleViewController].view.frame.size;
        }
        else if([rootVC isKindOfClass:[UITabBarController class]])
        {
            rootSize = [(UITabBarController *)rootVC selectedViewController].view.frame.size;
        }
        else
        {
            rootSize = [(UIViewController *)rootVC view].frame.size;
        }
        PYBannerView *bannerView = [[[PYBannerView alloc] initWithFrame:CGRectMake(0, (rootSize.height - 140) / 2, 320, 140)] autorelease];
        [bannerView setBannerType:BannerViewAny];
        bannerView.delegate = self;
        [bannerView setAdUnitId:@"zA.K4"];
        if([rootVC isKindOfClass:[UINavigationController class]])
        {
            [[(UINavigationController *)rootVC visibleViewController].view addSubview:bannerView];
        }
        else if([rootVC isKindOfClass:[UITabBarController class]])
        {
            [[(UITabBarController *)rootVC selectedViewController].view addSubview:bannerView];
        }
        else
        {
            [[(UIViewController *)rootVC view] addSubview:bannerView];
        }
        
        [bannerView loadAdInfo];
    }
}

#pragma mark - public

//固定位广告
+ (void)showAdViewWithFrame:(CGRect)rect
                  layerView:(UIView *)layerView
                   adUnitId:(NSString *)adUnitId
{
    [[Pinyou defaultLibManager] showAdViewWithFrame:rect
                                         layerView:layerView
                                          adUnitId:adUnitId];
}

+ (void)showBannerViewFormTopWithSize:(CGSize)size
                             adUnitId:(NSString *)adUnitId
{
    [[Pinyou defaultLibManager] showBannerViewFormTopWithSize:size adUnitId:adUnitId];
}

+ (void)showBannerViewFormBottomWithSize:(CGSize)size
                                adUnitId:(NSString *)adUnitId
{
    [[Pinyou defaultLibManager] showBannerViewFormBottomWithSize:size adUnitId:adUnitId];
}

+ (void)showStartupViewWithSize:(CGSize)size adUnitId:(NSString *)adUnitId
{
    [[Pinyou defaultLibManager] showStartupViewWithSize:size adUnitId:adUnitId];
}

+ (void)showInterstitialVideoWithAdUnitId:(NSString *)adUnitId
{
    [[Pinyou defaultLibManager] showInterstitialVideoWithAdUnitId:adUnitId];
}

+ (void)showInterstitialViewWithSize:(CGSize)size
                            adUnitId:(NSString *)adUnitId
{
    [[Pinyou defaultLibManager] showInterstitialViewWithSize:size adUnitId:adUnitId];
}

+ (void)showDefaultTopBannerView
{
    [[Pinyou defaultLibManager] showDefaultTopBannerView];
}

+ (void)showDefaultBottomBannerView
{
    [[Pinyou defaultLibManager] showDefaultBottomBannerView];
}

+ (void)showDefaultMiddleBannerView
{
    [[Pinyou defaultLibManager] showDefaultMiddleBannerView];
}

+ (NSString *)getPinyouSDKVersion
{
    return kPinYouSDKVersionString;
}

+ (NSString *)getPinyouId
{
    return @"PinyouId";
}

//Preload
+ (void)preloadAdInfo
{
    [[Pinyou defaultLibManager] preloadAdInfo];
}

- (void)preloadAdInfo
{
    PYBannerView *bannerViewTop = [[[PYBannerView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)] autorelease];
    [bannerViewTop setBannerType:BannerViewPreload];
    bannerViewTop.delegate = self;
    [bannerViewTop setAdUnitId:@"hA.3Y"];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:bannerViewTop];
    [bannerViewTop loadAdInfo];
    
    PYBannerView *bannerViewMiddle = [[[PYBannerView alloc] initWithFrame:CGRectMake(0, 0, 320, 140)] autorelease];
    [bannerViewMiddle setBannerType:BannerViewPreload];
    bannerViewMiddle.delegate = self;
    [bannerViewMiddle setAdUnitId:@"zA.K4"];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:bannerViewMiddle];
    [bannerViewMiddle loadAdInfo];
    
    PYBannerView *bannerViewBottom = [[[PYBannerView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)] autorelease];
    [bannerViewBottom setBannerType:BannerViewPreload];
    bannerViewBottom.delegate = self;
    [bannerViewBottom setAdUnitId:@"_A.fo"];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:bannerViewBottom];
    [bannerViewBottom loadAdInfo];
}

#pragma mark - PYBannerViewDelegate

- (void)bannerViewDidLoadImageData:(PYBannerView *)bannerView
{
    switch ([bannerView type])
    {
        case BannerViewAny:
        {
            
        }
            break;
        case BannerViewTop:
        {
            bannerView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, -(bannerView.frame.origin.y + bannerView.frame.size.height));
            [UIView animateWithDuration:kAnimationDurationDefault animations:^{
                bannerView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
        case BannerViewBottom:
        {
            bannerView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, bannerView.superview.frame.size.height - bannerView.frame.origin.y);
            [UIView animateWithDuration:kAnimationDurationDefault animations:^{
                bannerView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
        case BannerViewPreload:
        {
            bannerView.hidden = YES;
            [bannerView removeFromSuperview];
        }
            break;
        default:
            break;
    }
}

- (void)bannerViewDidLoadHTMLData:(PYBannerView *)bannerView
{
    switch ([bannerView type])
    {
        case BannerViewAny:
        {
            
        }
            break;
        case BannerViewTop:
        {
            bannerView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, -(bannerView.frame.origin.y + bannerView.frame.size.height));
            [UIView animateWithDuration:kAnimationDurationDefault animations:^{
                bannerView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
        case BannerViewBottom:
        {
            bannerView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, bannerView.superview.frame.size.height - bannerView.frame.origin.y);
            [UIView animateWithDuration:kAnimationDurationDefault animations:^{
                bannerView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
        case BannerViewPreload:
        {
            bannerView.hidden = YES;
            [bannerView removeFromSuperview];
        }
            break;
        default:
            break;
    }
}

- (void)bannerViewDidClickCloseButton:(PYBannerView *)bannerView finished:(PYBannerCloseBlock)closeBlock
{
    switch ([bannerView type])
    {
        case BannerViewAny:
        {
            closeBlock();
        }
            break;
        case BannerViewTop:
        {
            [UIView animateWithDuration:kAnimationDurationDefault animations:^{
                bannerView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, -(bannerView.frame.origin.y + bannerView.frame.size.height));
            } completion:^(BOOL finished) {
                closeBlock();
            }];
        }
            break;
        case BannerViewBottom:
        {
            [UIView animateWithDuration:kAnimationDurationDefault animations:^{
                bannerView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, bannerView.superview.frame.size.height - bannerView.frame.origin.y);
            } completion:^(BOOL finished) {
                closeBlock();
            }];
        }
            break;
        case BannerViewPreload:
        {
            bannerView.hidden = YES;
            closeBlock();
        }
            break;
        default:
            break;
    }
}

- (void)bannerViewDidLoadDataError:(PYBannerView *)bannerView error:(NSError *)error
{
//    NSLog(@"error domain = %@, error code = %i, error description = %@", error.domain, (int)error.code, error.description);
}

#pragma mark - PYInterstitialViewDelegate

- (void)interstitialViewDidLoadImageData:(PYInterstitialView *)interstitialView
{
    interstitialView.transform = CGAffineTransformMake(0, 0, 0, 0, 0, 0);
    interstitialView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:kAnimationDurationDefault animations:^{
        interstitialView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        interstitialView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    }];
}

- (void)interstitialViewDidLoadHTMLData:(PYInterstitialView *)interstitialView
{
    interstitialView.transform = CGAffineTransformMake(0, 0, 0, 0, 0, 0);
    interstitialView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:kAnimationDurationDefault animations:^{
        interstitialView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        interstitialView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    }];
}

- (void)interstitialViewDidClickCloseButton:(PYInterstitialView *)interstitialView finished:(PYInterstitialCloseBlock)closeBlock
{
    interstitialView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:kAnimationDurationDefault
                     animations:^{
                         interstitialView.transform = CGAffineTransformMake(0, 0, 0, 0, 0, 0);
                     } completion:^(BOOL finished) {
                         closeBlock();
                     }];
}

- (void)interstitialViewDidLoadDataError:(PYInterstitialView *)interstitialView error:(NSError *)error
{
//    NSLog(@"error domain = %@, error code = %i, error description = %@", error.domain, (int)error.code, error.description);
}

@end
