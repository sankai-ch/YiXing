//
//  SignUpViewController.m
//  ios_3_Acti
//
//  Created by admin on 2017/8/19.
//  Copyright © 2017年 Education. All rights reserved.
//

#import "SignUpViewController.h"
#import "NSString+Crypt.h"
#import "UserModel.h"

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *nickNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *numsTextField;
@property (weak, nonatomic) IBOutlet UIButton *numsBtn;
- (IBAction)numsAction:(UIButton *)sender forEvent:(UIEvent *)event;
@property (weak, nonatomic) IBOutlet UIButton *signUpAction;
@property (strong,nonatomic) UIActivityIndicatorView *avi;
@property (strong,nonatomic) NSString *diviceId;



@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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



//键盘收回
- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //让根视图结束编辑状态达到收起键盘的目的
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _userNameTextField || textField == _pwdTextField || textField == _nickNameTextField || textField == _confirmPwdTextField || textField == _numsTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)numsAction:(UIButton *)sender forEvent:(UIEvent *)event {
    if(_userNameTextField.text.length == 0 || _userNameTextField.text.length < 11){
        [Utilities popUpAlertViewWithMsg:@"请输入有效的手机号" andTitle:nil onView:self];
        return;
    }
    if(_pwdTextField.text.length == 0) {
        [Utilities popUpAlertViewWithMsg:@"请输入密码" andTitle:nil onView:self];
        return;
    }
    if(_pwdTextField.text.length < 6 || _pwdTextField.text.length > 18){
        [Utilities popUpAlertViewWithMsg:@"您输入的密码必须在6到18位之间" andTitle:nil onView:self];
        return;
    }
    if(_nickNameTextField.text.length == 0) {
        [Utilities popUpAlertViewWithMsg:@"请输入昵称" andTitle:nil onView:self];
        return;
    }
    if(![_confirmPwdTextField.text isEqualToString:_pwdTextField.text] ){
        [Utilities popUpAlertViewWithMsg:@"密码输入不一致，请重新输入" andTitle:nil onView:self];
        return;
    }
    //判断某个字符串中是否每个字符都是数字
    NSCharacterSet *notDigits = [[NSCharacterSet decimalDigitCharacterSet]invertedSet];
    if(_numsTextField.text.length == 0 ||[_numsTextField.text rangeOfCharacterFromSet:notDigits].location != NSNotFound) {
        [Utilities popUpAlertViewWithMsg:@"请输入有效的验证码" andTitle:nil onView:self];
        return;
    }
    if([_userNameTextField.text rangeOfCharacterFromSet:notDigits].location != NSNotFound ){
        [Utilities popUpAlertViewWithMsg:@"请输入有效手机号" andTitle:nil onView:self];
        return;
    }
}


#pragma mark - request
- (void)readyForEncoding{
    _avi = [Utilities getCoverOnView:self.view];
    _diviceId = [Utilities uniqueVendor];
    NSDictionary *para = @{@"deviceType":@7001,@"deviceId":_diviceId,@"userTel":_userNameTextField.text,@"userPwd":_pwdTextField.text,@"nickname":_nickNameTextField.text,@"city":[[StorageMgr singletonStorageMgr] objectForKey:@"cityId"],@"nums":};

    //网络请求
    [RequestAPI requestURL:@"/register" withParameters:para andHeader:nil byMethod:kGet andSerializer:kForm success:^(id responseObject) {
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            NSDictionary *result=responseObject[@"result"];
            NSString *exponent=result[@"exponent"];
            NSString *modulus=result[@"modulus"];
            //对密码内容进行md5加密
            NSString *md5Str = [_pwdTextField.text getMD5_32BitString];
            //用NSString+crpty和NSData+base64完成加密。
            //用模数与指数对md5加密后的密码加密
            NSString *rsaStr = [NSString encryptWithPublicKeyFromModulusAndExponent:md5Str.UTF8String modulus:modulus exponent:exponent];
            }else{
            [_avi stopAnimating];
        }
    } failure:^(NSInteger statusCode, NSError *error) {
        [_avi stopAnimating];
        [Utilities popUpAlertViewWithMsg:@"网络错误，请稍后再试" andTitle:@"提示" onView:self];
    }];
    
}


@end
