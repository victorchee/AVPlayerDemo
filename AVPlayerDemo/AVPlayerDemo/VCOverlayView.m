//
//  VCOverlayView.m
//  AVPlayerDemo
//
//  Created by Victor Chee on 2017/2/27.
//  Copyright © 2017年 VictorChee. All rights reserved.
//

#import "VCOverlayView.h"

@interface VCOverlayView()

@property (nonatomic, assign) BOOL controlsHidden;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL dragging;
@property (nonatomic, assign) CGFloat lastPlaybackRate;

@end

@implementation VCOverlayView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.timeSlider addTarget:self action:@selector(showPopupUI) forControlEvents:UIControlEventValueChanged];
    [self.timeSlider addTarget:self action:@selector(hidePopupUI) forControlEvents:UIControlEventTouchUpInside];
    [self.timeSlider addTarget:self action:@selector(unhidePopupUI) forControlEvents:UIControlEventTouchDown];
    
    [self resetTimer];
}

- (void)resetTimer {
    [self.timer invalidate];
    if (!self.dragging) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
            if (timer.isValid & !self.controlsHidden) {
                [self toggleControls:nil];
            }
        }];
    }
}

- (void)setCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration {
    NSInteger currentSeconds = ceilf(time);
    double remainingTime = duration - time;
    self.currentTimeLabel.text = [self formatSeconds:currentSeconds];
    self.remainingTimeLabel.text = [self formatSeconds:remainingTime];
    self.timeSlider.minimumValue = 0;
    self.timeSlider.maximumValue = duration;
    self.timeSlider.value = time;
}

- (void)setDragTime:(NSTimeInterval)time {
    self.draggingTimeLabel.text = [self formatSeconds:time];
}

- (NSString *)formatSeconds:(NSInteger)value {
    NSInteger seconds = value % 60;
    NSInteger minutes = value / 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long) minutes, (long) seconds];
}

- (IBAction)toggleControls:(UITapGestureRecognizer *)sender {
    [UIView animateWithDuration:0.35 animations:^{
        if (!self.controlsHidden) {
            
        } else {
            
        }
        self.controlsHidden = !self.controlsHidden;
    }];
}

- (IBAction)playButtonTapped:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    
    if (self.delegate) {
        SEL selector = sender.selected ? @selector(play) : @selector(pause);
        [self.delegate performSelector:selector];
    }
}

- (void)showPopupUI {
    self.currentTimeLabel.text = @"--:--";
    self.remainingTimeLabel.text = @"--:--";
    
    [self setDragTime:self.timeSlider.value];
    [self.delegate dragToTime:self.timeSlider.value];
}

- (void)hidePopupUI {
    self.dragging = NO;
    [self.delegate dragDidEnd];
}

- (void)unhidePopupUI {
    self.dragging = YES;
    [self resetTimer];
    [self.delegate dragDidStart];
}

- (void)setCurrentTime:(NSTimeInterval)time {
    [self.delegate jumpedToTime:time];
}

- (void)playbackComplete {
    self.timeSlider.value = 0;
    self.playButton.selected = NO;
}

@end
