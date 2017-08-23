//
//  SigninViewController.m
//  ios_3_Acti
//
//  Created by admin on 2017/8/19.
//  Copyright © 2017年 Education. All rights reserved.
//

#import "SigninViewController.h"
#import "NSString+Crypt.h"
#import "UserModel.h"
@interface SigninViewController ()
@property (strong,nonatomic)NSString *pwdtext;
@property (strong,nonatomic) NSString *diviceId;
@property (strong,nonatomic) UIActivityIndicatorView *avi;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)signInAction:(UIButton *)sender forEvent:(UIEvent *)event;


@end

@implementation SigninViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self naviConfig];
    [self uilayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)uilayout{
    if(![[Utilities getUserDefaults:@"Username"] isKindOfClass:[NSNull class]]){
        if([Utilities getUserDefaults:@"Username"]!=nil){
            _usernameTextField.text=[Utilities getUserDefaults:@"Username"];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//这个方法专门做导航条的控制
- (void)naviConfig{
    //设置导航条标题的文字
    self.navigationItem.title = @"";
    //设置导航条的颜色（风格颜色）
    self.navigationController.navigationBar.barTintColor = [UIColor grayColor];
    //设置导航条标题颜色
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    //设置导航条是否被隐藏
    self.navigationController.navigationBar.hidden = NO;
    
    //设置导航条上按钮的风格颜色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //设置是否需要毛玻璃效果
    self.navigationController.navigationBar.translucent = YES;
    //为导航条左上角创建一个按钮
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = left;
}
//用model的方式返回上一页
- (void)backAction{
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];//用push返回上一页
}
- (IBAction)signInAction:(UIButton *)sender forEvent:(UIEvent *)event {
    if(_usernameTextField.text.length == 0){
        [Utilities popUpAlertViewWithMsg:@"请输入您的手机号" andTitle:nil onView:self];
        return;
    }
    if(_passwordTextField.text.length == 0) {
        [Utilities popUpAlertViewWithMsg:@"请输入密码" andTitle:nil onView:self];
        return;
    }
    if(_passwordTextField.text.length < 6 || _passwordTextField.text.length > 18){
        [Utilities popUpAlertViewWithMsg:@"您输入的密码必须在6到18位之间" andTitle:nil onView:self];
        return;
    }
    //判断某个字符串中是否每个字符都是数字
     NSCharacterSet *notDigits = [[NSCharacterSet decimalDigitCharacterSet]invertedSet];
    if(_usernameTextField.text.length < 11 || [_usernameTextField.text rangeOfCharacterFromSet:notDigits].location != NSNotFound){
        [Utilities popUpAlertViewWithMsg:@"请输入有效手机号" andTitle:nil onView:self];
        return;
    }
    //无输入异常的情况下，，开始正式执行登录接口
    [self readyForEncoding];
    
}
#pragma mark - request
- (void)readyForEncoding{
    _avi = [Utilities getCoverOnView:self.view];
    _diviceId = [Utilities uniqueVendor];
    NSDictionary *para = @{@"deviceType":@7001,@"deviceId":_diviceId};
    NSLog(@"参数:%@",para);
    //网络请求 
    [RequestAPI requestURL:@"/login/getKey" withParameters:para andHeader:nil byMethod:kGet andSerializer:kForm success:^(id responseObject) {
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            NSDictionary *result=responseObject[@"result"];
            NSString *exponent=result[@"exponent"];
            NSString *modulus=result[@"modulus"];
            //对密码内容进行md5加密
            NSString *md5Str = [_passwordTextField.text getMD5_32BitString];
            //用NSString+crpty和NSData+base64完成加密。
            //用模数与指数对md5加密后的密码加密
            NSString *rsaStr = [NSString encryptWithPublicKeyFromModulusAndExponent:md5Str.UTF8String modulus:modulus exponent:exponent];
            //加密完成后执行登录接口
            [self signInWithEncryptPwd:rsaStr];
        }else{
            [_avi stopAnimating];
        }
    } failure:^(NSInteger statusCode, NSError *error) {
        [_avi stopAnimating];
        [Utilities popUpAlertViewWithMsg:@"网络错误，请稍后再试" andTitle:@"提示" onView:self];
    }];
    
}
- (void)signInWithEncryptPwd:(NSString *)encryptPwd {
    NSDictionary *para = @{@"userName":_usernameTextField.text,@"password":encryptPwd,@"deviceType":@7001,@"deviceId":_diviceId};
    [RequestAPI requestURL:@"/login" withParameters:para andHeader:nil byMethod:kPost andSerializer:kJson success:^(id responseObject) {
            [_avi stopAnimating];
        if([responseObject[@"resultFlag"] integerValue] == 8001){
            NSLog(@"%@",responseObject[@"result"]);
            NSDictionary *result=responseObject[@"result"];
            UserModel *user=[[UserModel alloc]initWhitDictionary:result];
            //将登陆获取到的用户信息打包存储到单例化全局变量中
            [[StorageMgr singletonStorageMgr]addKey:@"MemberInfo" andValue:user];
            //单独将用户的id也存储金单例化全局变量作为用户是否已经登陆的判断依据，同时也方便其他所有的页面更快捷的使用用户Id这个参数
            [[StorageMgr singletonStorageMgr]addKey:@"MemberId" andValue:user.memberId];
            //如果键盘还打开着让它收回去
            [self.view endEditing:YES];
            //清空密码输入框的内容，细节操作
            _passwordTextField.text=@"";
            //记忆用户名
            [Utilities setUserDefaults:@"Username" content:_usernameTextField];
            //用model的方式返回上一页，这全是细节操作。
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            NSString *errorMsg=[ErrorHandler getProperErrorString:[responseObject[@"resultFlag"]integerValue]];
            [Utilities popUpAlertViewWithMsg:errorMsg andTitle:nil onView:self];
        }
    } failure:^(NSInteger statusCode, NSError *error) {
        
    }];

}
//键盘收回
- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //让根视图结束编辑状态达到收起键盘的目的
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _usernameTextField || textField == _passwordTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}
@end
