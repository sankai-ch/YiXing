//
//  ActivityModel.h
//  ios_3_Acti
//
//  Created by admin1 on 2017/7/26.
//  Copyright © 2017年 Education. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityModel : NSObject
@property (strong,nonatomic) NSString *activityId;
@property (strong ,nonatomic) NSString *imgUrl;//活动图片URL字符串
@property (strong ,nonatomic) NSString *name;  //活动名称
@property (strong ,nonatomic) NSString *content;//活动内容
@property (nonatomic) NSInteger like;          //活动点赞数
@property (nonatomic) NSInteger unlike;        //活动被踩数
@property (nonatomic) BOOL isFavo;             //活动是否被收藏
@property (strong ,nonatomic) NSString *address;//活动地址
@property (strong ,nonatomic) NSString *applyFee;//报名费用
@property (strong ,nonatomic) NSString *attendence;//报名人数
@property (strong ,nonatomic) NSString *limitation;//限制人数
@property (strong ,nonatomic) NSString *type;    //活动类型
@property (strong ,nonatomic) NSString *issuer; //
@property (strong ,nonatomic) NSString *phone;
@property (nonatomic) NSTimeInterval dueTime; //截止时间日期
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval endTime;
@property (nonatomic) NSInteger status;
- (id) initWhitDictionary: (NSDictionary *)dict;
-(id) initWithDetailDictionary:(NSDictionary *)dict;


@end
