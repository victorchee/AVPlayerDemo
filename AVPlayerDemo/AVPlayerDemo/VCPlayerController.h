//
//  VCPlayerController.h
//  AVPlayerDemo
//
//  Created by Victor Chee on 2017/2/27.
//  Copyright © 2017年 VictorChee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCPlayerController : NSObject

@property (nonatomic, readonly, strong) UIView *view;

- (instancetype)initWithURL:(NSURL *)url;

@end
