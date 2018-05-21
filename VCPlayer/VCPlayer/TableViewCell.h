//
//  TableViewCell.h
//  VCPlayer
//
//  Created by Migu on 2018/4/13.
//  Copyright © 2018年 VIctorChee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (nonatomic, copy) void (^playButtonTappedHandler)(UIButton *sender);
@end
