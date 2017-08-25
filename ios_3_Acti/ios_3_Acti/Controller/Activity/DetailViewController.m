//
//  DetailViewController.m
//  ios_3_Acti
//
//  Created by admin1 on 2017/8/1.
//  Copyright © 2017年 Education. All rights reserved.
//

#import "DetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *activityImageView;
@property (weak, nonatomic) IBOutlet UILabel *applyFeeLbl;
- (IBAction)applyAction:(UIButton *)sender forEvent:(UIEvent *)event;
@property (weak, nonatomic) IBOutlet UIButton *applyBtn;
@property (weak, nonatomic) IBOutlet UILabel *applyStateLbl;
@property (weak, nonatomic) IBOutlet UILabel *attendenceLbl;
@property (weak, nonatomic) IBOutlet UILabel *issuerLbl;
@property (weak, nonatomic) IBOutlet UILabel *typeLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *addressLbl;
@property (weak, nonatomic) IBOutlet UIButton *phoeBtn;
- (IBAction)callAction:(UIButton *)sender forEvent:(UIEvent *)event;
@property (weak, nonatomic) IBOutlet UILabel *applyDueLbl;
@property (weak, nonatomic) IBOutlet UIView *applyStartView;
@property (weak, nonatomic) IBOutlet UIView *applStartDueView;

@property (weak, nonatomic) IBOutlet UIView *applendView;

@property (weak, nonatomic) IBOutlet UIView *applyIngeView;
@property (weak, nonatomic) IBOutlet UILabel *cantentLbl;

@property (strong,nonatomic) NSMutableArray *array;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
      _array = [NSMutableArray new];
    // Do any additional setup after loading the view.
    [self naviConfig];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self networkRequest];
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
    self.navigationItem.title = _activity.name;
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
}

- (IBAction)applyAction:(UIButton *)sender forEvent:(UIEvent *)event {
}
- (IBAction)callAction:(UIButton *)sender forEvent:(UIEvent *)event {
}


-(void)networkRequest{
    //菊花膜
    UIActivityIndicatorView *aiv = [Utilities getCoverOnView:self.view];
    
    NSString *request = [NSString stringWithFormat:@"/event/%@",_activity.activityId];
      NSMutableDictionary *parameters = [NSMutableDictionary new];
    if([Utilities loginCheck]){
        [parameters  setObject:[[StorageMgr singletonStorageMgr] objectForKey:@"MenberId"] forKey:@"memberId"];
        
    }
  
    
    [RequestAPI requestURL:request withParameters:parameters andHeader:nil byMethod:kGet andSerializer:kForm success:^(id responseObject) {
        [aiv stopAnimating];
        NSLog(@"111%@",responseObject);
          if ([responseObject[@"resultFlag"] integerValue] == 8001) {
              
              NSDictionary *result = responseObject[@"result"];
              _activity = [[ActivityModel alloc]initWithDetailDictionary:result];
              [self uiLayout];
            
          }
          else
          {
              //业务逻辑失败的情况下
              NSString *errorMsg = [ErrorHandler getProperErrorString:[responseObject[@"resultFlag"] integerValue]];
              [Utilities popUpAlertViewWithMsg:errorMsg andTitle:nil onView:self];
          }
    }
    failure:^(NSInteger statusCode, NSError *error)
    {
        [aiv stopAnimating];
        [Utilities popUpAlertViewWithMsg:@"请保持网络连接畅通" andTitle:nil onView:self];
    }];
    
}
- (void)uiLayout
{
    
    [_activityImageView sd_setImageWithURL:[NSURL URLWithString:_activity.imgUrl] placeholderImage:[UIImage imageNamed:@"png2"]];
    _applyFeeLbl.text = [NSString stringWithFormat:@"%@元",_activity.applyFee];
    _attendenceLbl.text = [NSString stringWithFormat:@"%@/%@",_activity.attendence,_activity.limitation];
    _timeLbl.text = _activity.type;
    _issuerLbl.text = _activity.issuer;
    _addressLbl.text = _activity.address;
    _cantentLbl.text = _activity.content;
    [_phoeBtn setTitle:[NSString stringWithFormat:@"联系活动发布者:%@",_activity.phone] forState:UIControlStateNormal];
    
}
@end
