//
//  PYInterstitialView.m
//  AdLib
//
//  Created by lide on 14-5-4.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import "PYInterstitialView.h"
#import "PYModel.h"
#import "PYAdRequest.h"
#import "PYModelRequest.h"
#import "AppInfoCollect.h"
#import "PYImageManager.h"
#import "PYOfflineSyncManager.h"
#import "PYAdUtility.h"

@interface PYInterstitialView () <UIWebViewDelegate>

@end

@implementation PYInterstitialView
{
    UIImageView     *_imageView;
    UIWebView       *_webView;
    UIButton        *_closeButton;
    
    id<PYInterstitialViewDelegate>  _delegate;
    PYModel         *_model;
    NSString        *_adUnitId;
    
    BOOL            _autoDismiss;
    NSUInteger      _autoRefreshTime;
    BOOL            _autoRefreshEnable;
}

@synthesize delegate = _delegate;
@synthesize adUnitId = _adUnitId;
@synthesize autoDismiss = _autoDismiss;
@synthesize autoRefreshTime = _autoRefreshTime;

#pragma mark - private

- (void)clickCloseButton:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(interstitialViewDidClickCloseButton:finished:)])
    {
        [_delegate interstitialViewDidClickCloseButton:self finished:^{
            [self removeFromSuperview];
            _autoRefreshTime = 0;
        }];
    }
    else
    {
        [self removeFromSuperview];
        _autoRefreshTime = 0;
    }
}

#pragma mark - super

+ (void)initialize
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
//    dispatch_async(dispatch_get_current_queue(), ^{
//        
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"YYYYMMdd"];
//        
//        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://fm.p0y.cn/m/mobilead.json?d=%@", [dateFormatter stringFromDate:[NSDate date]]]]];
//        
//        // 从配置文件中读取各项配置
//        // 无广告返回时是否显示缓存内容
//        BOOL showCache = NO;
//        // 回收应用列表周期
//        NSInteger appsCycle = 7;
//        // 回收应用列表地址
//        NSString *appsUrl = @"http://statstest.ipinyou.com/mcvt";
//        // 点击事件打开url时是否由Safari打开
//        id openInSafariExist = [[NSUserDefaults standardUserDefaults] objectForKey:@"openInSafari"];
//        
//        NSDate *now = [NSDate date];
//        
//        if(data != nil)
//        {
//            NSDictionary *dictionary = [PYAdUtility dictionaryWithJSONData:data];
//            if(dictionary != nil)
//            {
//                if([dictionary objectForKey:@"showCache"])
//                {
//                    showCache = [[dictionary objectForKey:@"showCache"] boolValue];
//                }
//                if ([dictionary objectForKey:@"appListSendCycle"])
//                {
//                    appsCycle = [[dictionary objectForKey:@"appListSendCycle"] integerValue];
//                }
//                if ([dictionary objectForKey:@"appListRecieveUrl"])
//                {
//                    appsUrl =[dictionary objectForKey:@"appListRecieveUrl"];
//                }
//                if ((openInSafariExist == nil) && [dictionary objectForKey:@"openInSafari"]) {
//                    BOOL openInSafari = [[dictionary objectForKey:@"openInSafari"] boolValue];
//                    [[NSUserDefaults standardUserDefaults] setBool:openInSafari forKey:@"openInSafari"];
//                }
//            }
//        }
//        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"appListLastSend"]) {
//            NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"appListLastSend"];
//            NSDate *interval = [now dateByAddingTimeInterval:-appsCycle*24*60*60];
//            NSComparisonResult result = [interval compare:lastDate];
//            if (result == NSOrderedDescending) {
//                AppInfoCollect *appInfoCollection = [AppInfoCollect defaultManager];
//                [appInfoCollection sendAppList: appsUrl];
//                [[NSUserDefaults standardUserDefaults]setObject:now forKey:@"appListLastSend"];
//            }
//        }
//        else {
//            AppInfoCollect *appInfoCollection = [AppInfoCollect defaultManager];
//            [appInfoCollection sendAppList: appsUrl];
//            [[NSUserDefaults standardUserDefaults]setObject:now forKey:@"appListLastSend"];
//        }
//        
//        [[NSUserDefaults standardUserDefaults] setBool:showCache forKey:@"showCache"];
//        
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        
//        [dateFormatter release];
//    });
    
    [pool drain];
}

- (id)initWithSize:(CGSize)size
{
    return [self initWithFrame:CGRectMake(0, 0, size.width, size.height)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        self.hidden = YES;
        
        _autoDismiss = NO;
        _autoRefreshTime = 0;
        _autoRefreshEnable = YES;
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - frame.size.width) / 2, (self.frame.size.height - frame.size.height) / 2, frame.size.width, frame.size.height)];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.userInteractionEnabled = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
        [self addSubview:_imageView];
        
        UITapGestureRecognizer *oneFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerTap:)];
        [_imageView addGestureRecognizer:oneFingerTap];
        [oneFingerTap release];
        
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake((self.frame.size.width - frame.size.width) / 2, (self.frame.size.height - frame.size.height) / 2, frame.size.width, frame.size.height)];
        _webView.delegate = self;
        _webView.scalesPageToFit = NO;
        _webView.hidden = YES;
        [self addSubview:_webView];
        
        UIView *view = [[[UIView alloc] initWithFrame:_webView.bounds] autorelease];
        view.backgroundColor = [UIColor clearColor];
        [_webView addSubview:view];
        
        UITapGestureRecognizer *oneFingerTapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerTap:)];
        [view addGestureRecognizer:oneFingerTapView];
        [oneFingerTapView release];
        
        _closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _closeButton.frame = CGRectMake(_imageView.frame.origin.x + _imageView.frame.size.width - 45, _imageView.frame.origin.y + 5, 40, 40);
        _closeButton.backgroundColor = [UIColor clearColor];
        NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"Pinyou" withExtension:@"bundle"]];
        [_closeButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"py_btn_close" ofType:@"png"]] forState:UIControlStateNormal];
        [_closeButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"py_btn_close_highlight" ofType:@"png"]] forState:UIControlStateHighlighted];
        [_closeButton addTarget:self action:@selector(clickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeButton];
    }
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    
    PY_VIEW_RELEASE(_imageView);
    _webView.delegate = nil;
    PY_VIEW_RELEASE(_webView);
    PY_VIEW_RELEASE(_closeButton);
    PY_SAFE_RELEASE(_model);
    PY_SAFE_RELEASE(_adUnitId);
    
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)loadAdInfo
{
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
    
    if(_adUnitId == nil || [_adUnitId isEqualToString:@""])
    {
        NSError *error = [NSError errorWithDomain:@"com.ipinyou" code:20001 userInfo:[NSDictionary dictionaryWithObject:@"没有设置广告主ID" forKey:@"NSLocalizedDescriptionKey"]];
        [self loadPreloadInfoBeforeSendError:error];
        
        return;
    }
    
    PYAdRequest *request = [PYAdRequest requestWithAdUnitId:_adUnitId];
    [request loadRequestSuccess:^(id responseObject) {
        if(_model != nil)
        {
            PY_SAFE_RELEASE(_model);
        }
        _model = [[PYModel alloc] initWithAttribute:responseObject];
        
        if([_model.mimeType isEqualToString:@"application/rss+xml"])
        {
            _imageView.hidden = NO;
            _webView.hidden = YES;
            [[PYImageManager defaultManager] downloadImageWithURL:_model.imageURL
                                                          success:^(UIImage *image, BOOL finished) {
                                                              
                                                              if(!finished)
                                                              {
                                                                  
                                                              }
                                                              else
                                                              {
                                                                  if(image == nil)
                                                                  {
                                                                      NSError *error = [NSError errorWithDomain:@"com.ipinyou" code:30001 userInfo:[NSDictionary dictionaryWithObject:@"图片读取失败" forKey:@"NSLocalizedDescriptionKey"]];
                                                                      [self loadPreloadInfoBeforeSendError:error];
                                                                      
                                                                      return;
                                                                  }
                                                                  
                                                                  _imageView.image = image;
                                                                  
                                                                  if(_delegate && [_delegate respondsToSelector:@selector(interstitialViewDidLoadImageData:)])
                                                                  {
                                                                      [self show];
                                                                      [_delegate interstitialViewDidLoadImageData:self];
                                                                  }
                                                                  else
                                                                  {
                                                                      [self show];
                                                                  }
                                                                  
                                                                  if([[NSUserDefaults standardUserDefaults] boolForKey:@"showCache"])
                                                                  {
                                                                      UIGraphicsBeginImageContextWithOptions(_imageView.frame.size, NO, 0.0);
                                                                      CGContextRef context = UIGraphicsGetCurrentContext();
                                                                      [_imageView.layer renderInContext:context];
                                                                      UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                                                                      UIGraphicsEndImageContext();
                                                                      
                                                                      NSData *modelData = UIImagePNGRepresentation(image);
                                                                      _model.modelData = modelData;
                                                                      
                                                                      [self archiveData:[NSArray arrayWithObject:_model] IntoCache:_model.adUnitId];
                                                                  }
                                                                  else
                                                                  {
                                                                      [self clearCacheInfo];
                                                                  }
                                                                  
//                                                                  if(_type != BannerViewPreload)
//                                                                  {
//                                                                      dispatch_queue_t queue = dispatch_queue_create("com.ipinyou.show", NULL);
//                                                                      for(NSUInteger i = 0; i < [_model.trackURLArray count]; i++)
//                                                                      {
//                                                                          dispatch_sync(queue, ^{
//                                                                              
//                                                                              __block PYModelRequest *modelRequest = [_model.trackURLArray objectAtIndex:i];
//                                                                              [modelRequest loadRequestSuccess:^(id responseObject) {
//                                                                                  
//                                                                              } failure:^(NSError *error) {
//                                                                                  [[PYOfflineSyncManager defaultManager] addOfflineModelRequest:modelRequest];
//                                                                              }];
//                                                                          });
//                                                                      }
//                                                                      dispatch_release(queue);
//                                                                  }
                                                              }
                                                          } failure:^(NSError *error) {
                                                              [self loadPreloadInfoBeforeSendError:error];
                                                          }];
        }
        else
        {
            _imageView.hidden = YES;
            _webView.hidden = NO;
            [_webView loadHTMLString:_model.htmlSnippet baseURL:nil];
        }
    } failure:^(NSError *error) {
        
        if(error.code == 20012)
        {
            [self clearCacheInfo];
            
            if([_delegate respondsToSelector:@selector(interstitialViewDidLoadDataError:error:)])
            {
                [_delegate interstitialViewDidLoadDataError:self error:error];
            }
        }
        else
        {
            if([[NSUserDefaults standardUserDefaults] boolForKey:@"showCache"])
            {
                [self loadPreloadInfoBeforeSendError:error];
            }
            else
            {
                NSError *error = [NSError errorWithDomain:@"com.ipinyou" code:20013 userInfo:[NSDictionary dictionaryWithObject:@"服务端不想加载缓存" forKey:@"NSLocalizedDescriptionKey"]];
                if([_delegate respondsToSelector:@selector(interstitialViewDidLoadDataError:error:)])
                {
                    [_delegate interstitialViewDidLoadDataError:self error:error];
                }
            }
        }
        
    }];
    
    if(_autoRefreshTime > 0)
    {
        [self performSelector:@selector(autoRefresh) withObject:nil afterDelay:_autoRefreshTime];
    }
}

- (void)autoRefresh
{
    if(_autoRefreshEnable)
    {
        [self performSelector:@selector(loadAdInfo) withObject:nil afterDelay:0];
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *padding = @"document.body.style.margin='0';document.body.style.padding='0'";
    [_webView stringByEvaluatingJavaScriptFromString:padding];
    
    if(_delegate && [_delegate respondsToSelector:@selector(interstitialViewDidLoadHTMLData:)])
    {
        [self show];
        [_delegate interstitialViewDidLoadHTMLData:self];
    }
    else
    {
        [self show];
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"showCache"])
    {
        UIGraphicsBeginImageContextWithOptions(_webView.frame.size, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [_webView.layer renderInContext:context];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *modelData = UIImagePNGRepresentation(image);
        _model.modelData = modelData;
        
        [self archiveData:[NSArray arrayWithObject:_model] IntoCache:_model.adUnitId];
    }
    else
    {
        [self clearCacheInfo];
    }
    
//    if(_type != BannerViewPreload)
//    {
//        dispatch_queue_t queue = dispatch_queue_create("com.ipinyou.show", NULL);
//        for(NSUInteger i = 0; i < [_model.trackURLArray count]; i++)
//        {
//            dispatch_sync(queue, ^{
//                
//                __block PYModelRequest *modelRequest = [_model.trackURLArray objectAtIndex:i];
//                [modelRequest loadRequestSuccess:^(id responseObject) {
//                    
//                } failure:^(NSError *error) {
//                    [[PYOfflineSyncManager defaultManager] addOfflineModelRequest:modelRequest];
//                }];
//            });
//        }
//        dispatch_release(queue);
//    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self loadPreloadInfoBeforeSendError:error];
}

#pragma mark - UIGestureRecognizer

- (void)oneFingerTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if(_model.openURLArray && [_model.openURLArray count] > 0)
        {
            NSString *clickString = [[_model.openURLArray objectAtIndex:0] requestURLString];
            
            if([clickString rangeOfString:@"%%TIMESTAMP%%"].location != NSNotFound)
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
                NSString *string = [dateFormatter stringFromDate:[NSDate date]];
                
                clickString = [clickString stringByReplacingOccurrencesOfString:@"%%TIMESTAMP%%" withString:string];
                [dateFormatter release];
            }
            
            BOOL openInSafari = [[NSUserDefaults standardUserDefaults] boolForKey:@"openInSafari"] ;
                                 
            if (openInSafari) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:clickString]];
                
            } else {
                if (_delegate && [_delegate respondsToSelector:@selector(customOpenClickUrl:withClickUrl:)]) {
                    [_delegate customOpenClickUrl:self withClickUrl:clickString];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:clickString]];
                }
            }
            
           // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:clickString]];
            
            dispatch_queue_t queue = dispatch_queue_create("com.ipinyou.click", NULL);
            for(NSUInteger i = 1; i < [_model.openURLArray count]; i++)
            {
                dispatch_sync(queue, ^{
                    
                    __block PYModelRequest *modelRequest = [_model.openURLArray objectAtIndex:i];
                    [modelRequest loadRequestSuccess:^(id responseObject) {
                        
                    } failure:^(NSError *error) {
                        [[PYOfflineSyncManager defaultManager] addOfflineModelRequest:modelRequest];
                    }];
                });
            }
            dispatch_release(queue);
        }
        
        if(_delegate && [_delegate respondsToSelector:@selector(interstitialViewDidTapInterstitial:finished:)])
        {
            [_delegate interstitialViewDidTapInterstitial:self finished:^{
                [self removeFromSuperview];
                _autoRefreshTime = 0;
            }];
        }
        else
        {
            [self removeFromSuperview];
            _autoRefreshTime = 0;
        }
    }
}

#pragma mark - public

- (void)show
{
    self.hidden = NO;
    
    if(_autoDismiss)
    {
        [self performSelector:@selector(hide) withObject:nil afterDelay:10.0];
    }
}

- (void)hide
{
    if(_delegate && [_delegate respondsToSelector:@selector(interstitialViewDidClickCloseButton:finished:)])
    {
        [_delegate interstitialViewDidClickCloseButton:self finished:^{
            [self removeFromSuperview];
        }];
    }
    else
    {
        [self removeFromSuperview];
    }
}

- (void)loadPreloadInfoBeforeSendError:(NSError *)error
{
    _autoRefreshEnable = NO;
    NSArray *array = [self unarchiveDataFromCache:_adUnitId];
    if(array && [array isKindOfClass:[NSArray class]] && [array count] > 0)
    {
        PYModel *model = [array objectAtIndex:0];
        if(_model != nil)
        {
            PY_SAFE_RELEASE(_model);
        }
        _model = [model retain];
        UIImage *image = [UIImage imageWithData:model.modelData];
        if(image != nil)
        {
            _imageView.image = image;
            if(_delegate && [_delegate respondsToSelector:@selector(interstitialViewDidLoadImageData:)])
            {
                [self show];
                [_delegate interstitialViewDidLoadImageData:self];
            }
            else if(_delegate && [_delegate respondsToSelector:@selector(interstitialViewDidLoadHTMLData:)])
            {
                [self show];
                [_delegate interstitialViewDidLoadHTMLData:self];
            }
            else
            {
                [self show];
            }
            
//            if(_type != BannerViewPreload)
//            {
//                dispatch_queue_t queue = dispatch_queue_create("com.ipinyou.show", NULL);
//                for(NSUInteger i = 0; i < [_model.trackURLArray count]; i++)
//                {
//                    dispatch_sync(queue, ^{
//                        
//                        __block PYModelRequest *modelRequest = [_model.trackURLArray objectAtIndex:i];
//                        [modelRequest loadRequestSuccess:^(id responseObject) {
//                            
//                        } failure:^(NSError *error) {
//                            [[PYOfflineSyncManager defaultManager] addOfflineModelRequest:modelRequest];
//                        }];
//                    });
//                }
//                dispatch_release(queue);
//            }
        }
        else
        {
            if([_delegate respondsToSelector:@selector(interstitialViewDidLoadDataError:error:)])
            {
                [_delegate interstitialViewDidLoadDataError:self error:error];
            }
        }
    }
    else
    {
        if([_delegate respondsToSelector:@selector(interstitialViewDidLoadDataError:error:)])
        {
            [_delegate interstitialViewDidLoadDataError:self error:error];
        }
    }
}

- (void)clearCacheInfo
{
    [self deleteArchiveDataWithPath:_model.adUnitId];
}

- (void)deleteArchiveDataWithPath:(NSString *)path
{
    if (!path || ![path length]) {
        return;
    }
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
    //    myPath = [myPath stringByAppendingPathComponent:path];
    myPath = [taskPath stringByAppendingPathComponent:path];
    
    [[NSFileManager defaultManager] removeItemAtPath:myPath error:&err];
}

- (void)archiveData:(NSArray *)array IntoCache:(NSString *)path
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
    dispatch_release(queue);
}

- (NSArray *)unarchiveDataFromCache:(NSString *)path
{
    if (!path || ![path length]) {
        return;
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
    else
    {
    }
    if (fData == nil ) {
        return nil;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithData:fData];
}

@end
