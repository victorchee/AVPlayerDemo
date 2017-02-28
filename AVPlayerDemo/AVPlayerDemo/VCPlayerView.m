//
//  VCPlayerView.m
//  AVPlayerDemo
//
//  Created by Victor Chee on 16/5/19.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

#import "VCPlayerView.h"
#import "VCOverlayView.h"

@interface VCPlayerView() {
}

@property (nonatomic, strong) VCOverlayView *overlayView;

@end

@implementation VCPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (instancetype)initWithPlayer:(AVPlayer *)player {
    if (self = [super initWithFrame:CGRectZero]) {
        self.backgroundColor = [UIColor blackColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [(AVPlayerLayer *)self.layer setPlayer:player];
        
        self.overlayView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([VCOverlayView class]) owner:self options:nil].firstObject;
        [self addSubview:self.overlayView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.overlayView.frame = self.bounds;
}

- (id<VCTransport>)transport {
    return self.overlayView;
}

@end
