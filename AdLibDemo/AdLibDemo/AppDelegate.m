//
//  AppDelegate.m
//  AdLibDemo
//
//  Created by lide on 14-2-18.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
//#import "UIImageView+WebCache.h"
//#import "SDWebImageDownloader.h"
//#import "SDWebImageManager.h"
//#import <AdSupport/AdSupport.h>
//#import "AFNetworking.h"
//#import "PYAdRequest.h"
#import "Pinyou.h"
#import "PYStartupView.h"
#import "PYStartupViewDelegate.h"
#import <SystemConfiguration/SystemConfiguration.h>

#include <sys/types.h>
#include <sys/sysctl.h>

#import "PYConversion.h"

@implementation AppDelegate

#pragma mark - private

#pragma mark - super

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //[PYAdRequest initSDKWithVersion:@"V1.0"];
    
//    PYStartupView *startupView = [[PYStartupView alloc]initWithSize:CGSizeMake(320, 470)] ;
//    startupView.delegate = self;
////    startupView.adUnitId = @"Jn.gj";//Rp.la
//    startupView.adUnitId = @"Rp.la";//Rp.la
//    [self.window addSubview:startupView];
//    [startupView loadAdInfo];
//    [startupView release];
    
    //经理人分享
//    [[PYConversion defaultManager] noticeConversionWithParamA:@"sj.1R" conversionTypeString:@"1453"];
    //网易
//    [[PYConversion defaultManager] noticeConversionWithParamA:@"uL.SR" conversionTypeString:@"2056"];
    //测试
//    [[PYConversion defaultManager] noticeConversionWithParamA:@"p.of" conversionTypeString:@"1958"];
    
    HomeViewController *homeVc = [[[HomeViewController alloc] init] autorelease];
    HomeViewController *homeVc1 = [[[HomeViewController alloc] init] autorelease];
    //    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:homeVc] autorelease];
    //    navigationController.navigationBarHidden = YES;
    UITabBarController *tabBarVC = [[UITabBarController alloc] init];
    tabBarVC.viewControllers = [NSArray arrayWithObjects:homeVc, homeVc1, nil];
    self.window.rootViewController = tabBarVC;
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)startupViewDidLoadImageData:(PYStartupView *)startupView
{
    NSLog(@"Success load image");
}
- (void)startupViewDidLoadDataError:(PYStartupView *)startupView error:(NSError *)error
{
    startupView.imageView.image = [UIImage imageNamed:@"Default@2x.png"];
    [startupView removeFromSuperview];
    startupView = nil;
    NSLog(@"error :%@",error);
}


- (void)startupViewCacheFaild:(PYStartupView *)startupView error:(NSError *)error
{
    NSLog(@"cache failed%@",error);
    [startupView removeFromSuperview];
    startupView = nil;
}
@end
