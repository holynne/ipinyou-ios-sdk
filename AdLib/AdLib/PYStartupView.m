//
//  PYStartupView.m
//  AdLib
//
//  Created by darren on 14-5-29.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import "PYStartupView.h"
#import "PYAdRequest.h"
#import "PYModelRequest.h"
#import "PYOfflineSyncManager.h"
#import "PYModel.h"
#import "PYImageManager.h"
@interface PYStartupView()

@end

@implementation PYStartupView
{
    PYModel *_model;
    
    id<PYStartupViewDelegate> _delegate;
    NSString *_adUnitId;
}

@synthesize adUnitId  = _adUnitId;
@synthesize delegate = _delegate;
#pragma mark -super

- (id)initWithSize:(CGSize)size
{
    return [self initWithFrame:CGRectMake(0, 20, size.width, size.height)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.userInteractionEnabled = false;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
//        _imageView.contentMode = UIViewContentModeScaleToFill;
        _imageView.layer.masksToBounds = YES;
        [self addSubview:_imageView];
        
        UIView *view = [[[UIView alloc] initWithFrame:_imageView.bounds] autorelease];
        view.backgroundColor = [UIColor clearColor];
//        NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"Pinyou" withExtension:@"bundle"]];
        
    }
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    PY_VIEW_RELEASE(_imageView);
    PY_SAFE_RELEASE(_model);
    PY_SAFE_RELEASE(_adUnitId);
    
    [super dealloc];
}


- (void)loadAdInfo
{
    if (_adUnitId == nil || [_adUnitId isEqualToString:@""]) {
        NSError *error = [NSError errorWithDomain:@"com.ipinyou" code:20001 userInfo:[NSDictionary dictionaryWithObject:@"没有设置广告主ID" forKey:@"NSLocalizedDescriptionKey"]];
        if ([_delegate respondsToSelector:@selector(startupViewDidLoadDataError:error:)]) {
            [_delegate startupViewDidLoadDataError:self error:error];
        }
        return;
    }
    id frequencyConfig = [[NSUserDefaults standardUserDefaults] objectForKey:@"startupFrequency"];
    if (frequencyConfig==nil) {
        NSInteger frequency = 2;
        [self loadCacheImageWithFrequency:frequency];
    }else {
        NSInteger frequency = [frequencyConfig integerValue];
        if (frequency > 0) {
            [self loadCacheImageWithFrequency:frequency];
        } else {
            NSError *error = [NSError errorWithDomain:@"com.ipinyou" code:20001 userInfo:[NSDictionary dictionaryWithObject:@"曝光频次已经达到上限" forKey:@"NSLocalizedDescriptionKey"]];
            if ([_delegate respondsToSelector:@selector(startupViewDidLoadDataError:error:)]) {
                [_delegate startupViewDidLoadDataError:self error:error];
            }
        }
    }
    [self cacheNewAdInfo];
    
}

- (void)loadCacheImageWithFrequency:(NSInteger) frequency
{
    NSArray *array = [self unarchiveDataFromCache:_adUnitId];
    if (array && [array isKindOfClass:[NSArray class]] && [array count] > 0) {
        PYModel *model = [array objectAtIndex:0];
        if(_model != nil)
        {
            PY_SAFE_RELEASE(_model);
        }
        _model = [model retain];
        UIImage *image = [UIImage imageWithData:model.modelData];
        if (image != nil) {
            _imageView.image = image;
            if (_delegate && [_delegate respondsToSelector:@selector(startupViewDidLoadImageData:)])
            {
                [_delegate startupViewDidLoadImageData:self];
            }
            frequency--;
            [[NSUserDefaults standardUserDefaults] setInteger:frequency forKey:@"startupFrequency" ];
            dispatch_queue_t queue = dispatch_queue_create("com.ipinyou.show", NULL);
            for(NSUInteger i = 0; i < [_model.trackURLArray count]; i++)
            {
                dispatch_sync(queue, ^{
                    
                    __block PYModelRequest *modelRequest = [_model.trackURLArray objectAtIndex:i];
                    [modelRequest loadRequestSuccess:^(id responseObject) {
                        
                    } failure:^(NSError *error) {
                        [[PYOfflineSyncManager defaultManager] addOfflineModelRequest:modelRequest];
                    }];
                });
            }
            dispatch_release(queue);
        } else {
//            NSError *error = [NSError errorWithDomain:@"com.ipinyou" code:20001 userInfo:[NSDictionary dictionaryWithObject:@"无缓存数据" forKey:@"NSLocalizedDescriptionKey"]];
            NSError *error = [NSError errorWithDomain:@"com.ipinyou" code:20001 userInfo:[NSDictionary dictionaryWithObject:@"缓存图片加载失败" forKey:@"NSLocalizedDescriptionKey"]];
            if ([_delegate respondsToSelector:@selector(startupViewDidLoadDataError:error:)]) {
                [_delegate startupViewDidLoadDataError:self error:error];
            }
        }
    }else {
        NSError *error = [NSError errorWithDomain:@"com.ipinyou" code:20001 userInfo:[NSDictionary dictionaryWithObject:@"无缓存数据" forKey:@"NSLocalizedDescriptionKey"]];
        if ([_delegate respondsToSelector:@selector(startupViewDidLoadDataError:error:)]) {
            [_delegate startupViewDidLoadDataError:self error:error];
        }
    }
    [[NSUserDefaults standardUserDefaults] setInteger:frequency forKey:@"startupFrequency"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}


//- (void)loadPreloadInfoBeforeSendError:(NSError *)error
//{
//    NSArray *array = [self unarchiveDataFromCache:_adUnitId];
//    
//    if ( array && [array isKindOfClass:[NSArray class]] && [array count] >0)
//    {
//        PYModel *model = [array objectAtIndex:0];
//        if (_model != nil) {
//            PY_SAFE_RELEASE(_model);
//        }
//        _model = [_model retain];
//        UIImage *image = [UIImage imageWithData:model.modelData];
//        if (image != nil)
//        {
//            _imageView.image = image;
//            
//            if (_delegate && [_delegate respondsToSelector:@selector(startupViewDidLoadImageData:)])
//            {
//                [_delegate startupViewDidLoadImageData:self];
//            }
//        }
//        else
//        {
//            if ([_delegate respondsToSelector:@selector(startupViewDidLoadDataError:error:)]) {
//                [_delegate startupViewDidLoadDataError:self error:error];
//            }
//        }
//    }
//    else
//    {
//        if ([_delegate respondsToSelector:@selector(startupViewDidLoadDataError:error:)]) {
//            [_delegate startupViewDidLoadDataError:self error:error];
//        }
//    }
//    
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}

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
    if (fData == nil ) {
        return nil;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithData:fData];
}

- (void)cacheNewAdInfo
{
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    dispatch_async(dispatch_get_current_queue(), ^{
        PYAdRequest *request = [PYAdRequest requestWithAdUnitId:_adUnitId];
        [request loadRequestSuccess:^(id responseObject) {
            if (_model != nil) {
                PY_SAFE_RELEASE(_model);
            }
            _model = [[PYModel alloc] initWithAttribute:responseObject];
            //TODO 未来需要对mime类型判断
            NSString *imageUrlString =@"";
            if (_model.imageURL != nil && ![_model.imageURL isEqualToString:@""]) {
                imageUrlString = _model.imageURL;
            } else if (_model.htmlSnippet !=nil && ![_model.htmlSnippet isEqualToString:@""]) {
                NSString *html = _model.htmlSnippet;
                NSRange rangeImg = [html rangeOfString:@"<img.*src=(.*?)[^>]*?>"
                                               options:NSRegularExpressionSearch];
                if (rangeImg.location != NSNotFound) {
                    NSString *imageString = [html substringWithRange:rangeImg];
                    NSRange rangeSrc = [imageString rangeOfString:@"http:\"?(.*?)(\"|>|\\s+)"
                                                          options:NSRegularExpressionSearch];
                    if (rangeSrc.location != NSNotFound) {
                        rangeSrc.length--;
                        imageUrlString = [imageString substringWithRange:rangeSrc];
                    }
                }
                _model.imageURL = imageUrlString;
                
            }
            NSInteger initFrequency = [[[NSUserDefaults standardUserDefaults] objectForKey:@"initFrequency"] integerValue];
            [[NSUserDefaults standardUserDefaults] setInteger:initFrequency forKey:@"startupFrequency"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            BOOL cacheImageFlag = YES;
            //TODO 判断图片url是否变化
            NSArray *array = [self unarchiveDataFromCache:_adUnitId];
            if (array && [array isKindOfClass:[NSArray class]] && [array count] > 0) {
                PYModel *cacheModel =  [array objectAtIndex:0] ;
                if ([cacheModel.imageURL isEqualToString:_model.imageURL] && (cacheModel.modelData != nil)) {
                    cacheImageFlag = NO;
                    _model.modelData = cacheModel.modelData;
                    //edit by 爱彬
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_group_t group = dispatch_group_create();
                    dispatch_group_async(group, queue, ^{
                        //操作1
                        [self deleteArchiveDataWithPath:_model.adUnitId];
                    });
                    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                        //全部操作都结束之后的处理操作
                        [self archiveData:[NSArray arrayWithObjects:_model, nil] IntoCache:_model.adUnitId];
                    });
                    dispatch_release(group);
                    //原代码
//                    [self deleteArchiveDataWithPath:_model.adUnitId];
//                    [self archiveData:[NSArray arrayWithObjects:_model, nil] IntoCache:_model.adUnitId];
                    
                }

            }
            if (cacheImageFlag && [imageUrlString length] > 0) {
                [[PYImageManager defaultManager] downloadImageWithURL:imageUrlString success:^(UIImage *image, BOOL finished) {
                    if (!finished) {
                    } else {
                        if (image == nil) {
                            NSError *error = [NSError errorWithDomain:@"com.ipinyou"
                                                                 code:30001
                                                             userInfo:[NSDictionary dictionaryWithObject:@"图片拉取失败"
                                                                                                  forKey:@"NSLocalizedDescriptionKey"]];
                            if (_delegate && [_delegate respondsToSelector:@selector(startupViewCacheFaild:error:)]) {
                                [_delegate startupViewCacheFaild:self error:error];
                            }
                            return;
                        }
                        //_imageView.image = image;
                        
                        //UIGraphicsBeginImageContextWithOptions(_imageView.frame.size, NO, 0.0);
                        //CGContextRef context = UIGraphicsGetCurrentContext();
                        //[_imageView.layer renderInContext:context];
                       // UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                        //UIGraphicsEndImageContext();
                        
                        NSData *modelData = UIImagePNGRepresentation(image);
                        _model.modelData = modelData;
                        [self archiveData:[NSArray arrayWithObject:_model] IntoCache:_model.adUnitId];
                        
                    }
                } failure:^(NSError *error) {
                    if (_delegate && [_delegate respondsToSelector:@selector(startupViewCacheFaild:error:)]) {
                        [_delegate startupViewCacheFaild:self error:error];
                    }
                }];
            }
        } failure:^(NSError *error) {
            if(error.code == 20012)
            {
                if([_delegate respondsToSelector:@selector(startupViewCacheFaild:error:)])
                {
                    [_delegate startupViewCacheFaild:self error:error];
                }
            }
        }];
        
    });
    
   // [pool drain];
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
//        NSLog(@"PYLog路径不存在,创建:%@",myPath);
//        NSFileManager *fileManager = [NSFileManager defaultManager ];
//        NSError *createError = nil;
//        [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&createError];
//        if (createError != nil) {
//            NSLog(@"创建文件目录出错:%@",createError);
//        }else{
//            NSLog(@"创建文件目录成功");
//        }
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

- (void)deleteArchiveDataWithPath:(NSString *)path
{
    if (!path || ![path length]) {
        return;
    }
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *myPath    = [myPathList  objectAtIndex:0];
    NSError *err        = nil;
    
    NSString *taskPath = [NSString stringWithFormat:@"%@/pyad",myPath];
//    myPath = [myPath stringByAppendingPathComponent:path];
    myPath = [taskPath stringByAppendingPathComponent:path];

    [[NSFileManager defaultManager] removeItemAtPath:myPath error:&err];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
