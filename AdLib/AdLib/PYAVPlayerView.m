//
//  PYAVPlayerView.m
//  AdLib
//
//  Created by 陈爱彬 on 15/3/20.
//  Copyright (c) 2015年 lide. All rights reserved.
//

#import "PYAVPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

#ifdef DEBUG
#define PYDebugLog(...) NSLog(__VA_ARGS__)
#define PYDebugMethod() NSLog(@"%s", __func__)
#else
#define PYDebugLog(...)
#define PYDebugMethod()
#endif

static NSString *const kAdVideoURL = @"adVideoUrl";

@interface PYAVPlayerView()

@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) UIButton *closeButton;
@property (nonatomic,strong) UIImageView *defaultLoadImageView;
@property (nonatomic,strong) NSDictionary *adInfoDict;
@end

@implementation PYAVPlayerView

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}
#pragma mark - UI视图

#pragma mark - 按钮响应方法
- (void)onVideoCloseButtonTapped
{
    [self.player pause];

    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self removeFromSuperview];
}
#pragma mark - 广告数据请求
//加载广告信息
- (void)loadAdInfo
{
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"video1" ofType:@"mp4"];
    NSString *serverVideoPath = @"http://220.181.117.175/117/15/110/letv-gug/17/ver_00_22-33193832-avc-575961-aac-64428-14920-1218954-1e210bbdfc5ed203870334a5079a4cfb-1425031000016.letv?crypt=25aa7f2e131400&b=1314&nlh=3072&nlt=45&bf=8000&p2p=1&video_type=mp4&termid=0&tss=no&geo=CN-1-5-1&platid=100&splatid=10000&its=0&keyitem=platid,splatid,its&ntm=1458381600&nkey=08f585c02f492f715b3f8f7d864dea60&proxy=1780933168,1032384080&gugtype=1&mmsid=27377177&type=pc_gaoqing_mp4&errc=0&gn=820&buss=1&qos=5&cips=101.36.89.234";
    self.adInfoDict = @{kAdVideoURL: serverVideoPath};
    [self createAvPlayer];
}
#pragma mark - 视频播放
- (void)createAvPlayer
{
    //添加本视图，否则会release
    self.backgroundColor = [UIColor blackColor];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    self.center = window.center;
    [window addSubview:self];
    [window bringSubviewToFront:self];
    //初始化设置
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    //初始化frame和url
    CGRect playerFrame = CGRectMake(0, 0, self.layer.bounds.size.width, self.layer.bounds.size.height);
    NSString *videoUrlString = _adInfoDict[kAdVideoURL];
    NSURL *videoUrl;
    if ([videoUrlString hasPrefix:@"http"]) {
        videoUrl = [NSURL URLWithString:videoUrlString];
    }else{
        videoUrl = [NSURL fileURLWithPath:videoUrlString];
    }
    self.player = [AVPlayer playerWithURL:videoUrl];
    //构建AVPlayerLayer
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = playerFrame;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.layer addSublayer:playerLayer];
    //添加关闭按钮
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 25, -20, 40, 40);
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"Pinyou" withExtension:@"bundle"]];
    [_closeButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"py_btn_close" ofType:@"png"]] forState:UIControlStateNormal];
    [_closeButton setBackgroundImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"py_btn_close_highlight" ofType:@"png"]] forState:UIControlStateHighlighted];
    [_closeButton addTarget:self action:@selector(onVideoCloseButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_closeButton];
    //播放
    [self.player play];
    //检测视频加载状态
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoReachedEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
#pragma mark - 视频状态KVO监测
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        //读取视频加载状态
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        if (playerItem.status == AVPlayerStatusReadyToPlay) {
            //加载完成,准备播放
            NSLog(@"广告视频加载成功,ReadyToPlay");

        }else if (playerItem.status == AVPlayerStatusFailed) {
            //加载失败
            NSLog(@"广告视频加载失败:%@",playerItem.error);
        }else if (playerItem.status == AVPlayerStatusUnknown) {
            //未知
            NSLog(@"广告视频加载状态未知");
        }
    }
}
- (void)onVideoReachedEnd:(NSNotification *)notification
{
//    NSLog(@"播放到结尾，开始重新播放");
    AVPlayerItem *playerItem = self.player.currentItem;
    [playerItem seekToTime:kCMTimeZero];
    [self.player play];
}
@end
