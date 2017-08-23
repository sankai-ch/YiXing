//
//  UserModel.m
//  ios_3_Acti
//
//  Created by admin1 on 2017/8/23.
//  Copyright © 2017年 Education. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel
- (id) initWhitDictionary: (NSDictionary *)dict{
    self = [super init];//self调用者本身
    if (self){
        _memberId=[Utilities nullAndNilCheck:dict[@"memberId"] replaceBy:@"0"];
        _phone=[Utilities nullAndNilCheck:dict[@"contactTel"] replaceBy:@"未设置"];
        _nickname=[Utilities nullAndNilCheck:dict[@"memberName"] replaceBy:@"未命名"];
        _age=[Utilities nullAndNilCheck:dict[@"age"] replaceBy:@"0"];
        _dob=[Utilities nullAndNilCheck:dict[@"birthday"] replaceBy:@"未设置"];
        _idCardNo=[Utilities nullAndNilCheck:dict[@"identificationcard"] replaceBy:@"未设置"];
        _credit=[Utilities nullAndNilCheck:dict[@"memberPoint"] replaceBy:@"0"];
        _avatarUrl=[Utilities nullAndNilCheck:dict[@"memberUrl"] replaceBy:@""];
        _tokenkey=[Utilities nullAndNilCheck:dict[@"key"] replaceBy:@""];
        if([dict[@"memberSex"] isKindOfClass:[NSNull class]]){
            _gender=@"";
            
        }else{
            switch ([dict[@"memberSex"]integerValue]) {
                case 1:
                    _gender=@"男";
                    break;
                    case 2:
                    _gender=@"女";
                    
                default:
                    _gender=@"未设置";
                    break;
            }
        }
    }
    return self;

}
@end
