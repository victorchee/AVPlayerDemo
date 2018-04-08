//
//  UIView+VCPlayerControlView.h
//  VCPlayer
//
//  Created by Migu on 2018/4/8.
//  Copyright © 2018年 VIctorChee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCPlayerControlDelegate.h"

@interface UIView(VCPlayerControlView)
@property (nonatomic, weak) id<VCPlayerControlDelegate> delegate;

- (void)vcPlayerShowOrHideControlView;
- (void)vcPlayerShowControlView;
- (void)vcPlayerHideControlView;

- (void)vcPlayerResetControlView;
- (void)vcPlayerCancelAutoFadeOutControlView;

- (void)vcPlayerItemPlaying;
- (void)vcPlayerPlayEnd;

- (void)vcPlayerPlayButtonState:(BOOL)state;
- (void)vcPlayerLoadingActivity:(BOOL)animated;

- (void)vcPlayerDraggedTime:(CGFloat)draggedTime totalTime:(CGFloat)totalTime isForward:(BOOL)forward;
- (void)vcPlayerDraggedEnd;
- (void)vcPlayerCurrentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime sliderValue:(CGFloat)value;

- (void)vcPlayerLoadingProgress:(CGFloat)progress;
- (void)vcPlayerItemStatusFailed:(NSError *)error;

- (void)vcPlayerCellPlay;
@end
