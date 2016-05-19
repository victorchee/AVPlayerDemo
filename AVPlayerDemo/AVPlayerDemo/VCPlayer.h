//
//  VCPlayer.h
//  AVPlayerDemo
//
//  Created by Victor Chee on 16/5/19.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCPlayer : UIView

@property (nonatomic, strong) NSURL *videoURL;

- (instancetype)initWithFrame:(CGRect)frame andVideoURL:(NSURL *)url;

- (void)play;
- (void)pause;

@end