//
//  ActivityTableViewCell.h
//  ActivityList
//
//  Created by admin on 2017/7/25.
//  Copyright © 2017年 Education. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *activityImageView;
@property (weak, nonatomic) IBOutlet UILabel *activityLikeLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityUnLikeLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoBtn;

@end
