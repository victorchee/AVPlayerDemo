//
//  TableViewCell.m
//  VCPlayer
//
//  Created by Migu on 2018/4/13.
//  Copyright © 2018年 VIctorChee. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)playButtonTapped:(UIButton *)sender {
    if (self.playButtonTappedHandler) {
        self.playButtonTappedHandler(sender);
    }
}

@end
