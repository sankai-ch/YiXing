//
//  ActivityModel.h
//  ios_3_Acti
//
//  Created by admin1 on 2017/7/26.
//  Copyright © 2017年 Education. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityModel : NSObject

@property (strong ,nonatomic) NSString *imgUrl;//活动图片URL字符串
@property (strong ,nonatomic) NSString *name;  //活动名称
@property (strong ,nonatomic) NSString *content;//活动内容
@property (nonatomic) NSInteger like;          //活动点赞数
@property (nonatomic) NSInteger unlike;        //活动被踩数
@property (nonatomic) BOOL isFavo;             //活动是否被收藏


- (id) initWhitDictionary: (NSDictionary *)dict;


@end
