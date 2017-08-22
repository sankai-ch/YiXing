//
//  ViewController.m
//  ios_3_Acti
//
//  Created by admin1 on 2017/7/24.
//  Copyright © 2017年 Education. All rights reserved.
//

#import "ListViewController.h"
#import "ActivityTableViewCell.h"
#import "ActivityModel.h"
#import "UIImageView+WebCache.h"
#import "DetailViewController.h"
#import "IssueViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ListViewController ()<UITableViewDataSource ,UITableViewDelegate,CLLocationManagerDelegate>{
    NSInteger page;//页码
    NSInteger perPage;//每页多少个内容
    NSInteger totalPage;//多少页
    BOOL isLoding;//判断是不是在加载中
    BOOL firstVisit; //判断是否是第一次访问
}

@property (weak, nonatomic) IBOutlet UITableView *activityTableView;
@property (strong,nonatomic) NSMutableArray *arr;
- (IBAction)favoAction:(UIButton *)sender forEvent:(UIEvent *)event;
@property (strong, nonatomic) UIImageView *zoomIV;
@property (strong, nonatomic) UIActivityIndicatorView *aIV;//菊花膜
- (IBAction)searchAction:(UIBarButtonItem *)sender;
- (IBAction)switchAction:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIButton *cityBtn;

@property (strong, nonatomic) CLLocationManager *locMgr;
@property (strong, nonatomic) CLLocation *location;

@end

@implementation ListViewController

//第一次将要开始渲染这个页面的时候
- (void)awakeFromNib{
    [super awakeFromNib];
}

//第一次来到这个页面的时候
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //_arr = @[@"骑行",@"锡马",@"登月",@"下海",@"棚户"];
    [self naviConfig];
    [self uiLayout];
    [self locationConfig];
    [self dataInitialize];
    
    
    
    //[self networkRequest];
    //过2秒再执行networkRequest方法
    //[self performSelector:@selector(networkRequest) withObject:nil afterDelay:2];
    
    
//    ActivityModel *activity = [[ActivityModel alloc] init];
//    activity.name = @"活动";
    
    
}

//每次将要来到这个页面的时候
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self locationStart];
}

//每次到达了这个页面的时候
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

//每次将要离开这个页面的时候
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_locMgr stopUpdatingLocation];
}

//每次离开这个页面
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //获得当前页面的导航控制器所维系的关于导航关系的数组,判断该数组中是否包含自己来得知当前操作是离开本页面还是退出本页面
    if(![self.navigationController.viewControllers containsObject:self]){
       //在这里先释放所有监听（包括：Action事件；Protocol：协议；Gesture手势；Notification通知...）所有通过故事版添加德控件都会自动释放
        
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//一旦退出这个页面的时候（并且所有的监听都已经全部释放了）
- (void)dealloc {
    //在这里释放所有内存（设置为nil）
}

//这个方法专门处理定位的基本设置
- (void)locationConfig {
    //初始化
    _locMgr = [CLLocationManager new];
    //签协议
    _locMgr.delegate = self;
    //识别定位到的设备位移多少距离进行一次识别
    _locMgr.distanceFilter = kCLDistanceFilterNone;
    //设置地球分割成边长多少精度的方块
    _locMgr.desiredAccuracy = kCLLocationAccuracyBest;
}

//这个方法处理开始定位
- (void)locationStart {
    //判断用户有没有选择过是否使用定位
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        //询问用户是否愿意使用定位
#ifdef __IPHONE_8_0
        if ([_locMgr respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            //使用“使用中打开定位”这个策略去运用定位功能
            [_locMgr requestWhenInUseAuthorization];
        }
#endif
    }
    //打开定位服务的开关（开始定位）
    [_locMgr startUpdatingLocation];
}


//这个方法专门做导航条的控制
- (void)naviConfig{
    //设置导航条标题的文字
    self.navigationItem.title = @"活动列表";
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

//这个方法专门做界面的时候
- (void)uiLayout{
    //为表格视图创建footer(该方法可以去除表格视图底部多余的下划线)
    _activityTableView.tableFooterView = [UIView new];
    //创建下拉刷新器
    [self refreshConfiguration];
    
}

- (void)refreshConfiguration{
    //初始化一个下拉刷新控件
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    //打下标
    refreshControl.tag = 10001;
    //设置标题
    NSString *title = @"让小胖的菊花转起来🔞";
    //创建属性字典
    NSDictionary *attrDict = @{NSForegroundColorAttributeName : [UIColor grayColor], NSBackgroundColorAttributeName : [UIColor clearColor]};//NSBackgroundColorAttributeName设置@"让小胖的菊花转起来"的背景颜色
    //将文字和属性字典包裹一个带属性的字符串
    NSAttributedString *attriTitle = [[NSAttributedString alloc] initWithString:title attributes:attrDict];
    refreshControl.attributedTitle = attriTitle;
    //设置下拉刷新指示器颜色(菊花颜色)
    refreshControl.tintColor = [UIColor blackColor];
    //设置背景色
    refreshControl.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //定义用户触发下拉事件时执行的方法
    [refreshControl addTarget:self action:@selector(refreshPage) forControlEvents:UIControlEventValueChanged];
    //将下拉刷新控件添加activityTableView中 (在tableView中，下拉刷新控件会自动放置在表格视图顶部后侧位置)
    [self.activityTableView addSubview:refreshControl];
}
/*
- (void)refreData:(UIRefreshControl *)sender{
    //过2秒再执行end方法
    [self performSelector:@selector(end) withObject:nil afterDelay:2];
}
*/
- (void)end{
    //在activityTableView中，根据下标10001获得其子视图:下拉刷新控件
    UIRefreshControl *refresh = (UIRefreshControl *)[self.activityTableView viewWithTag:10001];
    //结束刷新
    [refresh endRefreshing];
}

//这个方法专门做数据的处理
- (void)dataInitialize{
    BOOL appInit = NO;
    if ([[Utilities getUserDefaults:@"UserCity"] isKindOfClass:[NSNull class]]) {
        //是第一次打开APP
        appInit = YES;
    } else {
        if ([Utilities getUserDefaults:@"UserCity"] == nil) {
            //第一次打开APP
            appInit = YES;
        }
    }
    if (appInit) {
        //第一次来到页面将默认城市与记忆城市同步
        NSString *userCity = _cityBtn.titleLabel.text;
        [Utilities setUserDefaults:@"UserCity" content:userCity];
    } else {
        //不是第一次来到APP则将记忆城市与按钮上的城市名反向同步
        NSString *userCity = [Utilities getUserDefaults:@"UserCity"];
        [_cityBtn setTitle:userCity forState:UIControlStateNormal];
        
    }
    
    firstVisit = YES;
    isLoding = NO;
    _arr = [NSMutableArray new];
    //创建菊花膜
    _aIV = [Utilities getCoverOnView:self.view];
    [self refreshPage];
    
}

- (void)refreshPage{
    page = 1;
    [self networkRequest];
}

//执行网络请求
- (void)networkRequest {
    perPage = 10;
//    NSDictionary *dictA = @{@"name" : @"骑行" ,@"content" : @"到处乱骑", @"like" : @80, @"unlike" : @1, @"imgURL" : @"http://7u2h3s.com2.z0.glb.qiniucdn.com/activityImg_2_0B28535F-B789-4E8B-9B5D-28DEDB728E9A", @"isFavo" : @YES};
//    NSDictionary *dictB = @{@"name" : @"雪浪山骑马" ,@"content" : @"到处乱骑，看啊看，踩呀踩，吹吹风", @"like" : @800, @"unlike" : @1, @"imgURL" : @"http://7u2h3s.com2.z0.glb.qiniucdn.com/activityImg_1_885E76C7-7EA0-423D-B029-2085C0F769E6", @"isFavo" : @NO};
//    NSDictionary *dictC = @{@"name" : @"黄浦江浮潜" ,@"content" : @"游啊游，游啊游，到处游啊游,游啊游，游啊游，到处游啊游游啊游", @"like" : @810, @"unlike" : @1, @"imgURL" : @"http://7u2h3s.com2.z0.glb.qiniucdn.com/activityImg_3_2ADCF0CE-0A2F-46F0-869E-7E1BCAF455C1", @"isFavo" : @NO};
    
    
//    NSMutableArray *array = [NSMutableArray arrayWithObjects:dictA,dictB,dictC, nil];
//    for (NSDictionary *dict in array) {
        //用ActivityModel类中定义的初始化方法initWhitDictionary: 将遍历得来的字典dict转换成为initWhitDictionary对象
//        ActivityModel *activityModel = [[ActivityModel alloc] initWhitDictionary:dict];
        //将上述实例化好的ActivityModel对象插入_arr数组中
//        [_arr addObject:activityModel];
//    }
    //刷新表格（重载数据）
//    [self.activityTableView reloadData];//reloadData重新加载activityTableView数据
    //_arr = @[dictA,dictB,dictC];
    
    //
    if (!isLoding) {
        isLoding = YES;
        //在这里开启一个真实的网络请求
        //设置接口地址
        NSString *request = @"/event/list";
        //设置接口入参
        NSDictionary *prarmeter = @{@"page" : @(page), @"perPage" : @(perPage) ,@"city" : _cityBtn.titleLabel.text};
        
        //开始请求
        [RequestAPI requestURL:request withParameters:prarmeter andHeader:nil byMethod:kGet andSerializer:kForm success:^(id responseObject) {
            //成功以后要做的事情
            NSLog(@"responseObject = %@",responseObject);
            [self endAnimation];
            if ([responseObject[@"resultFlag"] integerValue] == 8001) {
                //业务逻辑成功的情况下
                NSDictionary *result = responseObject[@"result"];
                NSArray *models = result[@"models"];
                NSDictionary *pagingInfo = result[@"pagingInfo"];
                totalPage = [pagingInfo[@"totalPage"] integerValue];
                
                if (page == 1) {
                    //清空数据
                    [_arr removeAllObjects];
                }
                
                for (NSDictionary *dict in models) {
                    //用ActivityModel类中定义的初始化方法initWhitDictionary: 将遍历得来的字典dict转换成为initWhitDictionary对象
                    ActivityModel *activityModel = [[ActivityModel alloc] initWhitDictionary:dict];
                    //将上述实例化好的ActivityModel对象插入_arr数组中
                    [_arr addObject:activityModel];
                }
                //刷新表格（重载数据）
                [self.activityTableView reloadData];//reloadData重新加载activityTableView数据
                
            }else{
                //业务逻辑失败的情况下
                NSString *errorMsg = [ErrorHandler getProperErrorString:[responseObject[@"resultFlag"] integerValue]];
                [Utilities popUpAlertViewWithMsg:errorMsg andTitle:nil onView:self];
            }
        } failure:^(NSInteger statusCode, NSError *error) {
            //失败以后要做的事情
            NSLog(@"statusCode = %ld",(long)statusCode);
            [self endAnimation];
            [Utilities popUpAlertViewWithMsg:@"请保持网络连接畅通" andTitle:nil onView:self];
        }];
    }
}

//这个方法处理网络请求未完成后所有不同类型的动画终止
- (void)endAnimation{
    isLoding = NO;
    [_aIV stopAnimating];
    [self end];
}

//设置表格视图一共有多少组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//设置表格视图中每一组有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arr.count;
    
}

//设置一个细胞将要出现的时候要做的事情
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //判断是不是最后一行细胞将要出现
    if (indexPath.row == _arr.count - 1) {
        //判断还有没有下一页存在
        if (page < totalPage) {
            //在这里执行上拉翻页的数据操作
            page++;
            [self networkRequest];
        }
    }
    
}


//设置每一组中每一行的细胞长什么样
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //根据某个具体的名字找到该名字在页面上对应的细胞
    ActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityCell" forIndexPath:indexPath];
    //deque 队列
    
    //根据当前正在渲染的细胞的行号，从对应数组中拿到这一行所匹配的活动字典
    ActivityModel *activity = _arr[indexPath.row];
    
    //将http请求的字符串转换为nsurl
    NSURL *URL = [NSURL URLWithString:activity.imgUrl];
    //将URL给NSData（下载图片）NSData二进制的数据流
    //NSData *data = [NSData dataWithContentsOfURL:URL];
    //让图片加载
    //cell.activityImageView.image = [UIImage imageWithData:data];
    //将上3句合并
    //cell.activityImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:activity.imgUrl]]];
    //依靠SDWebImage来异步地下载一张远程路径中的图片并三级缓存在项目中，同时为下载的时间周期过程中设置一张临时占位图
    [cell.activityImageView sd_setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"png2"]];
    //给图片添加单击手势
    [self addTapGestureRecognizer:cell.activityImageView];
    
    cell.activityNameLabel.text = activity.name;
    cell.activityInfLabel.text = activity.content;
    cell.activityLikeLabel.text = [NSString stringWithFormat:@"顶:%ld",(long)activity.like];
    cell.activityUnlikeLabel.text = [NSString stringWithFormat:@"踩:%ld",(long)activity.unlike];
    //给每一行的收藏按钮打上下标，用来区分它是哪一行的按钮
    cell.favoBtn.tag = 100000 + indexPath.row;
//    if (activity.isFavo) {
//        cell.favoBtn.titleLabel.text = @"取消收藏";
//    }else{
//        cell.favoBtn.titleLabel.text = @"收藏";
//    }
    //NSString *title = activity.isFavo ?@"取消收藏" :@"收藏";
    [cell.favoBtn setTitle:activity.isFavo ? @"取消收藏" : @"收藏" forState:UIControlStateNormal];
    [self addLongPress:cell];
    /*
    //组
    //indexPath.section;
    //行indexPath.row;
    //判断当前正在渲染的细胞属于第几行
    if (indexPath.row == 0) {
        //第一行
        //修改图片内容
        cell.activityImageView.image = [UIImage imageNamed:@"png2"];
        //修改标签的名字
        cell.activityNameLabel.text = @"环太湖骑行";
        cell.activityInfLabel.text = @"从无锡滨湖区雪浪街道太湖出发，经过南京，苏州，嘉兴，上海再返回无锡";
        cell.activityLikeLabel.text = @"顶:80";
        cell.activityUnlikeLabel.text = @"踩:1";
    }else{
       //第二行
        //修改图片内容
        cell.activityImageView.image = [UIImage imageNamed:@"鄱阳湖"];
        //修改标签的名字
        cell.activityNameLabel.text = @"环鄱阳湖游街";
        cell.activityInfLabel.text = @"经过每一条街道，吃遍每一条街道的美食";
        cell.activityLikeLabel.text = @"顶:800万";
        cell.activityUnlikeLabel.text = @"踩:1";
    }*/
    
    return cell;
    
}

//添加一个长按手势事件
- (void)addLongPress: (UITableViewCell *)cell{
    //初始化一个长按手势，设置它的响应事件为choose:
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(choose:)];
    //设置长按手势响应的时间
    longPress.minimumPressDuration = 1.5;
    //将手势添加给cell
    [cell addGestureRecognizer:longPress];
}
//添加一个单击手势事件
- (void)addTapGestureRecognizer: (id)any{
    //初始化一个单击手势，设置它的响应事件为tapClick:
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    //将手势添加给入参
    [any addGestureRecognizer:tap];
}
//小图单击手势响应事件
- (void)tapClick: (UITapGestureRecognizer *)tap{
    if (tap.state == UIGestureRecognizerStateRecognized){
    //NSLog(@"你单击了");
    //拿到单击手势在_activityTableView中的位置
    CGPoint location = [tap locationInView:_activityTableView];
    //通过上述的点拿到在_activityTableView对应的indexPath
    NSIndexPath *indexPath = [_activityTableView indexPathForRowAtPoint:location];
    //防范式编程
    if (_arr !=nil && _arr.count != 0){
        //根据行号拿到数组中对应的数据
        ActivityModel *activity = _arr[indexPath.row];
        //设置大图片的位置大小
        _zoomIV = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
        //用户交互启用
        _zoomIV.userInteractionEnabled = YES;
        //设置大图背景颜色
        _zoomIV.backgroundColor = [UIColor blackColor];
        //_zoomIV.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:activity.imgUrl]]];
        //将http请求的字符串转换为nsurl
        NSURL *URL = [NSURL URLWithString:activity.imgUrl];
        //依靠SDWebImage来异步地下载一张远程路径中的图片并三级缓存在项目中，同时为下载的时间周期过程中设置一张临时占位图
        [_zoomIV sd_setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"png2"]];
        //设置图片地内容模式
        _zoomIV.contentMode = UIViewContentModeScaleAspectFit;
        //[UIApplication sharedApplication].keyWindow获得窗口实例，并将大图放置到窗口实例上，根据苹果规则，后添加的控件会盖住前面添加的控件
        [[UIApplication sharedApplication].keyWindow addSubview:_zoomIV];
        UITapGestureRecognizer *zoomIVTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoomTap:)];
        [_zoomIV addGestureRecognizer:zoomIVTap];
        
    }
    }
}
//大图的单击手势响应事件
- (void)zoomTap: (UITapGestureRecognizer *)tap{
    if (tap.state == UIGestureRecognizerStateRecognized) {
        //把大图的本身东西扔掉
        [_zoomIV removeGestureRecognizer:tap];
        //把自己从父级视图中移除
        [_zoomIV removeFromSuperview];
        //彻底消失（这样就不会让内存滥用）
        _zoomIV = nil;
    }
}
//长按响应事件
- (void) choose:(UILongPressGestureRecognizer *)longPress{
    //判断手势的状态（长按手势有时间间隔，对应的会有开始和结束两钟状态）
    if (longPress.state == UIGestureRecognizerStateBegan) {
       //NSLog(@"长按了");
        //拿到长按手势在_activityTableView中的位置
        CGPoint location = [longPress locationInView:_activityTableView];
        //通过上述的点拿到在_activityTableView对应的indexPath
        NSIndexPath *indexPath = [_activityTableView indexPathForRowAtPoint:location];
        //防范式编程
        if (_arr !=nil && _arr.count != 0){
            //根据行号拿到数组中对应的数据
            ActivityModel *activity = _arr[indexPath.row];
            //创建弹窗控制器
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"复制操作" message:@"复制活动名称或内容" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *actionA = [UIAlertAction actionWithTitle:@"复制活动名称" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //创建一个复制版
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                //将活动名称复制
                [pasteboard setString:activity.name];
                //NSLog(@"%@",pasteboard.string);
                
            }];
            UIAlertAction *actionB = [UIAlertAction actionWithTitle:@"复制活动内容" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //创建一个复制版
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                //将活动内容复制
                [pasteboard setString:activity.content];
                //NSLog(@"%@",pasteboard.string);
            }];
            UIAlertAction *actionC = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:actionC];
            [alert addAction:actionA];
            [alert addAction:actionB];
            [self presentViewController:alert animated:YES completion:^{
                
            }];

        }
    }/*else if (longPress.state == UIGestureRecognizerStateEnded){
        NSLog(@"结束长按了");
    }*/
    
}

//设置每一组中每一行细胞的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //获取三要素（计算文字高度的三要素）
    //1.文字内容
    ActivityModel *activity = _arr[indexPath.row];
    NSString *activityContent = activity.content;
    //2.字体大小
    ActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityCell"];
    UIFont *font = cell.activityInfLabel.font;
    //3.宽度尺寸
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 30;
    CGSize size = CGSizeMake(width, 1000);
    //根据三元素计算尺寸
    CGFloat height = [activityContent boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : font} context:nil].size.height;
    //活动内容标签的原点y轴的位置+活动内容标签根据文字自适应大小后获得的高度+活动内容标签距离细胞底部的间距
    return cell.activityInfLabel.frame.origin.y + height + 10;
}

//设置每一组中没一行被点击以后要做的事情
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //判断当前这个tableView是否为_activityTableView（这个条件判断常在一个页面中有多个tableView的时候）
    if ([tableView isEqual:_activityTableView]) {
        //取消选中
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        
    }
    
    
}
//收藏按钮的事件
- (IBAction)favoAction:(UIButton *)sender forEvent:(UIEvent *)event {
    if (_arr !=nil && _arr.count != 0){
        //通过按钮的下标值去减100000拿到行号，再通过行号拿到对应的数据类型
        ActivityModel *activity = _arr[sender.tag - 100000];
        
        NSString *message = activity.isFavo ? @"是否取消收藏该活动" : @"是否收藏该活动";
        //创建弹出框，标题为@"提示"，内容为@"是否收藏该活动"
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
        //创建取消按钮
        UIAlertAction *actionA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {/*代码块（black）*/
            
        }];
        //创建确定按钮
        UIAlertAction *actionB = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (activity.isFavo) {
                activity.isFavo = NO;
            }else{
                activity.isFavo = YES;
            }
            
            [self.activityTableView reloadData];//reloadData重新加载activityTableView数据
        }];
        //将按钮添加到弹窗中，（添加按钮的顺序决定了按钮的排版:从左到右；从上到下，取消风格按钮会在左边）
        [alert addAction:actionA];
        [alert addAction:actionB];
        //将presentViewController的方法，以model的方式显示另一个页面（显示弹出框）
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }
}

//当某一个页面跳转行为将要发生的时候
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"List2Detail"]) {
        //当列表页到详情页的这个跳转要发生的时候
        //1.获取要传递到下一页的数据
        NSIndexPath *indexPath = [_activityTableView indexPathForSelectedRow];
        ActivityModel *activity = _arr[indexPath.row];
        //2.获取下一页的实例
        DetailViewController *detailVC = segue.destinationViewController;
        //3.把数据给下一页预备好的接收容器
        detailVC.activity = activity;
    }
}

- (IBAction)searchAction:(UIBarButtonItem *)sender {
    //1.获得要跳转的页面的实例
    IssueViewController *issueVC = [Utilities getStoryboardInstance:@"Issue" byIdentity:@"Issue"];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:issueVC];
    //2.用某种方式跳转到上述页面（这里用Model方式跳转）
    [self presentViewController:nc animated:YES completion:nil];
    //push跳转
    //[self.navigationController pushViewController:nc animated:YES];
}

- (IBAction)switchAction:(UIBarButtonItem *)sender {
    //发送注册按钮被按的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LeftSwitch" object:nil];
}

- (IBAction)cityAction:(UIButton *)sender forEvent:(UIEvent *)event {
}

//定位失败时
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    if (error) {
        switch (error.code) {
            case kCLErrorNetwork:
                [Utilities popUpAlertViewWithMsg:NSLocalizedString(@"NetworkError", nil) andTitle:nil onView:self];
                break;
            case kCLErrorDenied:
                [Utilities popUpAlertViewWithMsg:NSLocalizedString(@"GPSDisabled", nil) andTitle:nil onView:self];
                break;
            case kCLErrorLocationUnknown:
                [Utilities popUpAlertViewWithMsg:NSLocalizedString(@"LocationUnkonw", nil) andTitle:nil onView:self];
                break;
            default:
                [Utilities popUpAlertViewWithMsg:NSLocalizedString(@"SystemError", nil) andTitle:nil onView:self];
                break;
        }
    }
}


//定位成功时
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    NSLog(@"维度 ：%f",newLocation.coordinate.latitude);
    NSLog(@"经度 ：%f",newLocation.coordinate.longitude);
    _location = newLocation;
    //用flag思想判断是否可以去根据定位拿到城市
    if (firstVisit) {
        firstVisit = !firstVisit;
        //根据定位拿到城市
        [self getRegeoViaCoordinate];
    }
}


- (void)getRegeoViaCoordinate {
    //duration表示从NOW开始过三个SEC
    dispatch_time_t duration = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    //用duration这个设置好的策略去做某件事  GCD = dispatch
    dispatch_after(duration, dispatch_get_main_queue(), ^{
        //正式做事
        CLGeocoder *geo = [CLGeocoder new];
        //反向地理编码
        [geo reverseGeocodeLocation:_location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            if (!error) {
                //从placemarks中拿到地址信息
                //CLPlacemark *first = placemarks[0];
                CLPlacemark *first = placemarks.firstObject;
                NSDictionary *locDict = first.addressDictionary;
                
                NSLog(@"locDict = %@",locDict);
                NSString *cityStr = locDict[@"City"];
                cityStr = [cityStr substringToIndex:cityStr.length - 1];
                NSLog(@"city = %@",cityStr);
                if (![_cityBtn.titleLabel.text isEqualToString:cityStr]) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"当前定位到的城市为%@,是否切换？",cityStr] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        //修改城市按钮标题
                        [_cityBtn setTitle:cityStr forState:UIControlStateNormal];
                        //删除记忆体
                        [Utilities removeUserDefaults:@"UserCity"];
                        //添加记忆体
                        [Utilities setUserDefaults:@"UserCity" content:cityStr];
                        //网络请求
                        [self networkRequest];
                        
                    }];
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:confirm];
                    [alert addAction:cancel];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
        }];
        //三秒后关掉开关
        [_locMgr stopUpdatingLocation];
    });
}

@end
