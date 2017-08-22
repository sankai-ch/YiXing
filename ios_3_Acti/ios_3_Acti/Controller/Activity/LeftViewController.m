//
//  LeftViewController.m
//  ios_3_Acti
//
//  Created by admin on 2017/8/19.
//  Copyright © 2017年 Education. All rights reserved.
//

#import "LeftViewController.h"

@interface LeftViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) NSArray *arr;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *usernameLbl;
- (IBAction)loginAction:(UIButton *)sender forEvent:(UIEvent *)event;
- (IBAction)settingAction:(UIButton *)sender forEvent:(UIEvent *)event;
@property (weak, nonatomic) IBOutlet UILabel *actLabel;


@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self uiLayout];
    [self dataInitialize];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)uiLayout{
    _avatar.layer.borderColor=[UIColor lightGrayColor].CGColor;
}
- (void)dataInitialize{
    _arr = @[@"我的活动", @"我的推广", @"积分中心", @"意见反馈", @"关于我们"];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Table view data source
//组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}
//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _arr.count;
    }
    else{
        return 1;
    }
    
    

}

//表格样式
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0){
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MemberCell" forIndexPath:indexPath];
    cell.textLabel.text=_arr[indexPath.row];
    return cell;
    }
    else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyCell" forIndexPath:indexPath];
        return cell;
    }
}
//设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0)
    {
        return 50.f;
    }
    else{
        return  UI_SCREEN_H-500;
    }
}

//选中后的操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (IBAction)loginAction:(UIButton *)sender forEvent:(UIEvent *)event {
    //获取要跳转过去的页面
    UINavigationController *signNavi=[Utilities getStoryboardInstance:@"Member" byIdentity:@"SignNavi"];
    //执行跳转
    [self presentViewController:signNavi animated:YES completion:nil];
}

- (IBAction)settingAction:(UIButton *)sender forEvent:(UIEvent *)event {
}
@end
