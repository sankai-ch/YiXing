//
//  ActivityTableViewCell.h
//  ios_3_Acti
//
//  Created by admin1 on 2017/7/25.
//  Copyright © 2017年 Education. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *activityImageView;
@property (weak, nonatomic) IBOutlet UILabel *activityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityInfLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityLikeLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityUnlikeLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoBtn;

@end
