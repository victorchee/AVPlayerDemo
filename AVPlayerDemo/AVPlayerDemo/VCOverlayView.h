//
//  VCOverlayView.h
//  AVPlayerDemo
//
//  Created by Victor Chee on 2017/2/27.
//  Copyright © 2017年 VictorChee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCTransport.h"

@interface VCOverlayView : UIView <VCTransport>

@property (nonatomic, weak) id<VCTransportDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *draggingTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainingTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;

- (void)setCurrentTime:(NSTimeInterval)time;

@end
