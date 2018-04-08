//
//  VCPlayerControlDelegate.h
//  VCPlayer
//
//  Created by Migu on 2018/4/8.
//  Copyright © 2018年 VIctorChee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VCPlayerControlDelegate <NSObject>
@optional
- (void)playerControlView:(UIView *)controlView backAction:(UIButton *)sender;
- (void)playerControlView:(UIView *)controlView playAction:(UIButton *)sender;
- (void)playerControlView:(UIView *)controlView fullscreenAction:(UIButton *)sender;
- (void)playerControlView:(UIView *)controlView muteAction:(UIButton *)sender;

- (void)playerControlView:(UIView *)controlView progressSliderTap:(CGFloat)value;
- (void)playerControlView:(UIView *)controlView progressSliderTouchBegan:(UISlider *)slider;
- (void)playerControlView:(UIView *)controlView progressSliderValueChanged:(UISlider *)slider;
- (void)playerControlView:(UIView *)controlView progressSliderTouchEnded:(UISlider *)slider;

- (void)playerControlViewWillShow:(UIView *)controlView isFullscreen:(BOOL)fullscreen;
- (void)playerControlViewWillHide:(UIView *)controlView isFullscreen:(BOOL)fullscreen;
@end
