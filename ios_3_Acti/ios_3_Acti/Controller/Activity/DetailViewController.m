//
//  DetailViewController.m
//  ios_3_Acti
//
//  Created by admin1 on 2017/8/1.
//  Copyright © 2017年 Education. All rights reserved.
//

#import "DetailViewController.h"
#import "PurchaseTableViewController.h"
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
@property (strong, nonatomic)  UIImageView *image;

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
    if([Utilities loginCheck]){
        //从一个故事版跳到另一个故事版
        PurchaseTableViewController *purchaseVc = [Utilities getStoryboardInstance:@"Detail" byIdentity:@"Purchase"];
        [self.navigationController pushViewController:purchaseVc animated:YES];
        purchaseVc.activity = _activity;
    }else{
        UINavigationController *signNavi = [Utilities getStoryboardInstance:@"Member" byIdentity:@"SignNavi"];
        [self presentViewController:signNavi animated:YES completion:nil];
    }
}
- (IBAction)callAction:(UIButton *)sender forEvent:(UIEvent *)event {
    
    NSString *targetAppstr = [NSString stringWithFormat:@"telprompt://%@",_activity.phone];
    NSLog(@"%@",_activity.phone);
    //获取配置配置电话App的路径，并将要拨打的号码组合到路径中
    NSURL *targetAppUrl =[NSURL URLWithString:targetAppstr];
    ///从当前App跳转到其他指定的App中
    [[UIApplication sharedApplication]openURL:targetAppUrl];
    
}

//添加一个单击手势事件
- (void)addTapGestureRecognizer: (id)any{
    //初始化一个单击手势，设置它的响应事件为tapClick:
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    //用户交互启用
    _activityImageView.userInteractionEnabled = YES;
    //将手势添加给入参
    [any addGestureRecognizer:tap];
}
//小图单击手势响应事件
- (void)tapClick: (UITapGestureRecognizer *)tap{
    if (tap.state == UIGestureRecognizerStateRecognized){
        NSLog(@"你单击了");
        //拿到单击手势在_activityTableView中的位置
        //CGPoint location = [tap locationInView:_activityImageView];
        //通过上述的点拿到在_activityTableView对应的indexPath
        //NSIndexPath *indexPath = [_activityTableView indexPathForRowAtPoint:location];
        //防范式编程
        // if (_arr !=nil && _arr.count != 0){
        //根据行号拿到数组中对应的数据
        //  ActivityModel *activity = _arr[indexPath.row];
        //设置大图片的位置大小
        _image = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
        //用户交互启用
        _image.userInteractionEnabled = YES;
        //设置大图背景颜色
        _image.backgroundColor = [UIColor blackColor];
        //_image.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_activity.imgUrl]]];
        //将http请求的字符串转换为nsurl
        NSURL *URL = [NSURL URLWithString:_activity.imgUrl];
        //依靠SDWebImage来异步地下载一张远程路径中的图片并三级缓存在项目中，同时为下载的时间周期过程中设置一张临时占位图
        [_image sd_setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"png2"]];
        //设置图片地内容模式
        _image.contentMode = UIViewContentModeScaleAspectFit;
        //[UIApplication sharedApplication].keyWindow获得窗口实例，并将大图放置到窗口实例上，根据苹果规则，后添加的控件会盖住前面添加的控件
        [[UIApplication sharedApplication].keyWindow addSubview:_image];
        UITapGestureRecognizer *zoomIVTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoomTap:)];
        [_image addGestureRecognizer:zoomIVTap];
        
        // }
    }
}//大图的单击手势响应事件
- (void)zoomTap: (UITapGestureRecognizer *)tap{
    if (tap.state == UIGestureRecognizerStateRecognized) {
        //把大图的本身东西扔掉
        [_image removeGestureRecognizer:tap];
        //把自己从父级视图中移除
        [_image removeFromSuperview];
        //彻底消失（这样就不会让内存滥用）
       _image = nil;
    }
}


-(void)networkRequest{
    //菊花膜
    UIActivityIndicatorView *aiv = [Utilities getCoverOnView:self.view];
    
    NSString *request = [NSString stringWithFormat:@"/event/%@",_activity.activityId];
      NSMutableDictionary *parameters = [NSMutableDictionary new];
    if([Utilities loginCheck]){
        [parameters  setObject:[[StorageMgr singletonStorageMgr] objectForKey:@"MemberId"] forKey:@"memberId"];
        
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
    [self addTapGestureRecognizer:_activityImageView];
    _applyFeeLbl.text = [NSString stringWithFormat:@"%@元",_activity.applyFee];
    _attendenceLbl.text = [NSString stringWithFormat:@"%@/%@",_activity.attendence,_activity.limitation];
    //_applyStateLbl = _activi
    _typeLbl.text = _activity.type;
    _issuerLbl.text = _activity.issuer;
    _addressLbl.text = _activity.address;
    _cantentLbl.text = _activity.content;
    [_phoeBtn setTitle:[NSString stringWithFormat:@"联系活动发布者:%@",_activity.phone] forState:UIControlStateNormal];
    
    NSString *dueTimeStr =[Utilities dateStrFromCstampTime:_activity.dueTime withDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *startTimeStr =[Utilities dateStrFromCstampTime:_activity.startTime withDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *endTimeStr =[Utilities dateStrFromCstampTime:_activity.endTime withDateFormat:@"yyyy-MM-dd HH:mm"];
    _timeLbl.text = [NSString stringWithFormat:@"%@ - %@",startTimeStr,endTimeStr];
    _applyDueLbl.text = [NSString stringWithFormat:@"报名截止时间:%@",dueTimeStr];
    NSDate *now = [NSDate date];
    NSTimeInterval nowTime = [now timeIntervalSince1970InMilliSecond];
    _applyStartView.backgroundColor = [UIColor grayColor];
    if(nowTime >=_activity.dueTime){
        _applStartDueView.backgroundColor = [UIColor grayColor];
        _applyBtn.enabled = NO;
        [_applyBtn setTitle:@"报名截止" forState:UIControlStateNormal];
        if(nowTime >=_activity.startTime){
            _applyIngeView.backgroundColor = [UIColor grayColor];
            if(nowTime >= _activity.endTime){
                _applendView.backgroundColor = [UIColor grayColor];
            }
        }
      
        
    }
    if(_activity.attendence >= _activity.limitation){
        _applyBtn.enabled = NO;
        [_applyBtn setTitle:@"活动满员" forState:  UIControlStateNormal];
        
    }
    switch(_activity.status)
    {
        case 0:{
            _applyStateLbl.text = @"已取消";
        }break;
        case 1:{
            _applyStateLbl.text =@"待付款";
            [ _applyBtn setTitle:@"去付款" forState: UIControlStateNormal];
            
        }break;
             case 2:
        {
            _applyStateLbl.text =@"已报名";
            [ _applyBtn setTitle:@"已报名" forState: UIControlStateNormal];
            _applyBtn.enabled = NO;
        }break;
        case 3:{
            _applyStateLbl.text =@"退款中";
            [ _applyBtn setTitle:@"退款中" forState: UIControlStateNormal];
            _applyBtn.enabled = NO;
        }break;
        case 4:{
            _applyStateLbl.text =@"已退款";
        }break;
            
        default:{
            _applyStateLbl.text =@"待报名";
        }break;
    }
    
}
@end
