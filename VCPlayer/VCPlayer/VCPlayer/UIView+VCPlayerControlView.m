//
//  UIView+VCPlayerControlView.m
//  VCPlayer
//
//  Created by Migu on 2018/4/8.
//  Copyright © 2018年 VIctorChee. All rights reserved.
//

#import "UIView+VCPlayerControlView.h"
#import <objc/runtime.h>

@implementation UIView(VCPlayerControlView)

- (void)setDelegate:(id<VCPlayerControlDelegate>)delegate {
    objc_setAssociatedObject(self, @selector(delegate), delegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<VCPlayerControlDelegate>)delegate {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)vcPlayerShowOrHideControlView {}
- (void)vcPlayerShowControlView {}
- (void)vcPlayerHideControlView {}

- (void)vcPlayerResetControlView {}
- (void)vcPlayerCancelAutoFadeOutControlView {}

- (void)vcPlayerItemPlaying {}
- (void)vcPlayerPlayEnd {}

- (void)vcPlayerPlayButtonState:(BOOL)state {}
- (void)vcPlayerLoadingActivity:(BOOL)animated {}

- (void)vcPlayerDraggedTime:(CGFloat)draggedTime totalTime:(CGFloat)totalTime isForward:(BOOL)forward {}
- (void)vcPlayerDraggedEnd {}
- (void)vcPlayerCurrentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime sliderValue:(CGFloat)value {}

- (void)vcPlayerLoadingProgress:(CGFloat)progress {}
- (void)vcPlayerItemStatusFailed:(NSError *)error {}

- (void)vcPlayerCellPlay {}

@end
