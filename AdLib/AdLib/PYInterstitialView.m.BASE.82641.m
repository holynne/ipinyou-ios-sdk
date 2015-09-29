//
//  PYInterstitialView.m
//  AdLib
//
//  Created by lide on 14-2-19.
//  Copyright (c) 2014年 lide. All rights reserved.
//

#import "PYInterstitialView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PYInterstitialView

@synthesize delegate = _delegate;
@synthesize adUnitId = _adUnitId;

#pragma mark - private

- (void)clickCloseButton:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(interstitialViewDidClickCloseButton:)])
    {
        [_delegate interstitialViewDidClickCloseButton:self];
    }
}

#pragma mark - super

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - frame.size.width) / 2, (self.frame.size.height - frame.size.height) / 2, frame.size.width, frame.size.height)];
        _imageView.backgroundColor = [UIColor redColor];
        _imageView.userInteractionEnabled = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
        [self addSubview:_imageView];
        
        UITapGestureRecognizer *oneFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerTap:)];
        [_imageView addGestureRecognizer:oneFingerTap];
        [oneFingerTap release];
        
        _closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _closeButton.frame = CGRectMake(_imageView.frame.origin.x + frame.size.width - 50, _imageView.frame.origin.y + 10, 40, 40);
        _closeButton.backgroundColor = [UIColor whiteColor];
        [_closeButton setTitle:@"X" forState:UIControlStateNormal];
        [_closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _closeButton.layer.borderColor = [[UIColor blackColor] CGColor];
        _closeButton.layer.borderWidth = 1.0;
        [_closeButton addTarget:self action:@selector(clickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:_closeButton];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - UIGestureRecognizer

- (void)oneFingerTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if(_delegate && [_delegate respondsToSelector:@selector(interstitialViewDidTap:)])
        {
            [_delegate interstitialViewDidTap:self];
        }
    }
}

- (void)show
{
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
    self.alpha = 0.0;
    _imageView.transform = CGAffineTransformMake(0.8, 0, 0, 0.8, 0, 0);
    
    [UIView animateWithDuration:kAnimationDurationDefault
                     animations:^{
                         self.alpha = 1.0;
                         _imageView.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         [self addSubview:_closeButton];
                     }];
}

- (void)hide
{
    [_closeButton removeFromSuperview];
    [UIView animateWithDuration:kAnimationDurationDefault
                     animations:^{
                         self.alpha = 0.0;
                         _imageView.transform = CGAffineTransformMake(0.8, 0, 0, 0.8, 0, 0);
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

@end
