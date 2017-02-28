//
//  VCPlayerView.h
//  AVPlayerDemo
//
//  Created by Victor Chee on 16/5/19.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCTransport.h"

@interface VCPlayerView : UIView

- (instancetype)initWithPlayer:(AVPlayer *)player;

@property (nonatomic, readonly) id<VCTransport> transport;

@end
