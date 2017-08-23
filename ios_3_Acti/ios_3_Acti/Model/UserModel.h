//
//  UserModel.h
//  ios_3_Acti
//
//  Created by admin1 on 2017/8/23.
//  Copyright © 2017年 Education. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject
@property(strong,nonatomic)NSString *memberId;
@property(strong,nonatomic)NSString *phone;
@property(strong,nonatomic)NSString *nickname;
@property(strong,nonatomic)NSString *age;
@property(strong,nonatomic)NSString *dob;//出生日期
@property(strong,nonatomic)NSString *idCardNo;
@property(strong,nonatomic)NSString *gender;
@property(strong,nonatomic)NSString *credit;
@property(strong,nonatomic)NSString *avatarUrl;
@property(strong,nonatomic)NSString *tokenkey;

- (id) initWhitDictionary: (NSDictionary *)dict;

@end
