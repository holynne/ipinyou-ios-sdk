//
//  HomeViewController.m
//  AdLibDemo
//
//  Created by lide on 14-3-4.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import "HomeViewController.h"
#import "Pinyou.h"
#import "PYConversion.h"
#import <QuartzCore/QuartzCore.h>
#import "DownloadViewController.h"
//#import "PYBannerView.h"
#import "PYInterstitialView.h"
#import "PYInterstitialViewDelegate.h"
#import <MessageUI/MessageUI.h>

@interface HomeViewController ()
//<PYBannerViewDelegate>

@end

@implementation HomeViewController

- (void)clickBannerButton:(id)sender
{
    [Pinyou showBannerViewFormTopWithSize:CGSizeMake(300, 250) adUnitId:@"jq.KE"];
//    PYBannerView *bannerView = [[[PYBannerView alloc] initWithFrame:CGRectMake(0, 20, 320, 50)] autorelease];
//    [bannerView setShowCloseButton:NO];
//    bannerView.delegate = self;
//    bannerView.autoRefreshTime = 20;
////    [bannerView setAdUnitId:@"hA.3Y"];
////    [bannerView setAdUnitId:@"2n.yk"];
////    [bannerView setAdUnitId:@"rD.C7"];
//    [bannerView setAdUnitId:@"7D.Ue"];
//    [self.view addSubview:bannerView];
//    
//    [bannerView loadAdInfo];
    
//    [[PYConversion defaultManager] noticeConversionWithParamA:@"a5.Yo" conversionTypeString:@"1111"];
}

- (void)clickInterstitialButton:(id)sender
{
    [Pinyou showInterstitialVideoWithAdUnitId:@""];
//    [Pinyou showInterstitialViewWithSize:CGSizeMake(320, 240) adUnitId:@"Xi.VU"];
    
//    [Pinyou showBannerViewFormTopWithSize:CGSizeMake(340, 140) adUnitId:@"hA.3Y"];

    //[[PYConversion defaultManager] noticeConversionWithParamA:@"p.of" conversionType:PY_Pay];
}

- (void)clickCleanCacheButton:(id)sender
{

    NSArray *array = [self unarchiveDataFromCache:@"tn.RR"];
    
    
    NSString *alertContent = @"缓存已经清空,下次打开生效";
    if (array && [array count] > 0) {
//        NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *myPath    = [myPathList  objectAtIndex:0];
        NSError *err        = nil;
        //创建子目录
        BOOL isDir = NO;
        NSString *taskPath = [NSString stringWithFormat:@"%@/pyad",myPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:taskPath isDirectory:(&isDir)]) {
            [fileManager createDirectoryAtPath:taskPath withIntermediateDirectories:NO attributes:nil error:nil];
            isDir = YES;
        }
        //创建文件目录
        //    myPath = [myPath stringByAppendingPathComponent:@"tn.RR"];
        myPath = [taskPath stringByAppendingPathComponent:@"tn.RR"];
        
        [[NSFileManager defaultManager] removeItemAtPath:myPath error:&err];
        
    }else {
        alertContent = @"缓存中无数据,请下次再试";
    }
    UIAlertView *cleanAlert = [[UIAlertView alloc] initWithTitle:@"Success" message:alertContent delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [cleanAlert show];
    
}

- (NSArray *)unarchiveDataFromCache:(NSString *)path
{
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
    else
    {
    }
    if (fData == nil ) {
        return nil;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithData:fData];
}




#pragma mark - super

- (id)init
{
    self = [super init];
    if(self != nil)
    {
        
    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
    
    UIButton *bannerButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    bannerButton.frame = CGRectMake(100, 120, 120, 40);
    [bannerButton setTitle:@"Banner" forState:UIControlStateNormal];
    [bannerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    bannerButton.layer.borderColor = [[UIColor blackColor] CGColor];
    bannerButton.layer.borderWidth = 1.0;
    [bannerButton addTarget:self action:@selector(clickBannerButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bannerButton];
    
    UIButton *interstitialButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    interstitialButton.frame = CGRectMake(100, 165, 120, 40);
    [interstitialButton setTitle:@"Interstitial" forState:UIControlStateNormal];
    [interstitialButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    interstitialButton.layer.borderColor = [[UIColor blackColor] CGColor];
    interstitialButton.layer.borderWidth = 1.0;
    [interstitialButton addTarget:self action:@selector(clickInterstitialButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:interstitialButton];
    
    UIButton *cleanCacheButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    cleanCacheButton.frame = CGRectMake(100,220,120,40);
    [cleanCacheButton setTitle:@"清空缓存" forState:UIControlStateNormal];
    [cleanCacheButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    cleanCacheButton.layer.borderColor = [[UIColor blackColor] CGColor];
    cleanCacheButton.layer.borderWidth = 1.0;
    [cleanCacheButton addTarget:self action:@selector(clickCleanCacheButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cleanCacheButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PYMraidDelegate

- (UIViewController *)mraidViewController
{
    return self;
}
#pragma mark - PYPYBannerViewDelegate
//- (void)customOpenClickUrl:(PYBannerView *)bannerView withClickUrl:(NSString *)clickUrl {
//    NSLog(@"%@",clickUrl);
//}




@end
