//
//  ViewController.m
//  ActivityList
//
//  Created by admin on 2017/7/24.
//  Copyright © 2017年 Education. All rights reserved.
//

#import "ListViewController.h"
#import "ActivityTableViewCell.h"
#import "ActivityModel.h"
#import "UIImageView+WebCache.h"
#import "DetailViewController.h"
#import "IssueViewController.h"

@interface ListViewController () <UITableViewDataSource,UITableViewDelegate>
{
    NSInteger page;
    NSInteger perPage;
    NSInteger totalPage;
    BOOL isLoading;
}

@property (weak, nonatomic) IBOutlet UITableView *activityTableView;

@property (strong, nonatomic) NSMutableArray *arr;
- (IBAction)searchAction:(UIBarButtonItem *)sender;

@property (strong, nonatomic) UIImageView *zoomIV;

@property (strong, nonatomic) UIActivityIndicatorView *aiv;

- (IBAction)favoAction:(UIButton *)sender forEvent:(UIEvent *)event;

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
    [self naviConfig];
    [self uiLayout];
    [self dataInitialize];
    //过两秒执行netWorkRequest方法
    //[self performSelector:@selector(networkRequest) withObject:nil afterDelay:2];
    
    }

//每次将要来到这个页面的时候
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

//每次到达这个页面的时候
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

//每次将要离开这个页面的时候
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

//每次离开这个页面的时候
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //获得当前页面导航控制器所维系的关于导航关系的数组，通过判断该数组中是否包含自己来得知当前操作是离开本页面还是退出本页面
    if (![self.navigationController.viewControllers containsObject:self]) {
        //在这里先释放所有监听（包括：Action事件；protocol协议；Gesture手势；notification通知...）
        //所有通过storeboard故事板添加的控件以及监听都会自动释放。
        //所有设置为new的方法都有一个专用的方法来释放
    }
}

//一旦退出这个页面的时候（并且所有的监听都已经全部被释放）
- (void)dealloc{
    //在这里释放所有内存（nil）;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//这个方法专门做导航条的控制
- (void)naviConfig {
    //设置导航条标题文字
    self.navigationItem.title = @"活动列表";
    //设置导航条颜色（风格颜色）
    self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
    //设置导航条标题颜色
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    //设置导航条是否隐藏.
    self.navigationController.navigationBar.hidden = NO;
    //设置导航条上按钮的风格颜色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //设置是否需要毛玻璃效果
    self.navigationController.navigationBar.translucent = YES;
}

- (void)uiLayout {
    //为表格视图创建footer(该方法可以去除表格视图底部多余的下划线)
    _activityTableView.tableFooterView = [UIView new];
    //创建下拉刷新器
    [self refreshConfiguration];

}

- (void)refreshConfiguration{
    //初始化一个下拉刷新控件
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    
    refreshControl.tag = 10001;
    //设置标题
    NSString *title = @"加载中...";
    
    //创建属性字典
    NSDictionary *attrDict = @{NSForegroundColorAttributeName : [UIColor redColor],NSBackgroundColorAttributeName : [UIColor yellowColor]};
    
    
    //将文字和属性字典包裹成一个带属性的字符串
    NSAttributedString *attriTitle = [[NSAttributedString alloc]initWithString:title attributes:attrDict];
    
    refreshControl.attributedTitle = attriTitle;
    //设置风格颜色为黑色（风格颜色：刷新指示器的颜色）
    refreshControl.tintColor = [UIColor brownColor];
    
    //设置背景色
    refreshControl.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //定义用户触发下拉事件时执行的方法
    [refreshControl addTarget:self action:@selector(refreshPage) forControlEvents:UIControlEventValueChanged];
    //将下拉刷新控件添加到tableView中(在tableView中，下拉刷新控件会自动放置在表格视图顶部后侧位置)
    [self.activityTableView addSubview:refreshControl];
    
}
/*
- (void)refreData:(UIRefreshControl *)sender{
    //过两秒再执行end方法
    [self performSelector:@selector(end) withObject:nil afterDelay:2];
}
*/

- (void)end{
    //在activityTableView中，根据下标为10001获得其子视图：下拉刷新控件
    UIRefreshControl *refresh = (UIRefreshControl *)[self.activityTableView viewWithTag:10001];
    //结束刷新
    [refresh endRefreshing];
}

//这个方法专门做数据的处理
- (void)dataInitialize {
    isLoading = NO;
    _arr = [NSMutableArray new];
    //创建菊花膜
    _aiv = [Utilities getCoverOnView:self.view];
    [self refreshPage];
}

//
- (void)refreshPage {
    page = 1;
    [self networkRequest];
}

//执行网络请求
- (void)networkRequest{
    perPage = 10;
    /*
    NSDictionary *dictA = @{@"name" : @"环太湖骑行", @"content": @"从无锡滨湖区到雪浪街道太湖边出发，往东绕过苏州、嘉兴、湖州、宜兴，返回无锡", @"like" : @80, @"unlike" : @8, @"imgURL" : @"http://7u2h3s.com2.z0.glb.qiniucdn.com/activityImg_2_0B28535F-B789-4E8B-9B5D-28DEDB728E9A", @"isFavo" : @YES};
    NSDictionary *dictB = @{@"name" : @"雪浪山骑马", @"content": @"踏着薰衣草的香味，让马儿漫步在山间", @"like" : @16, @"unlike" : @2, @"imgURL" : @"http://7u2h3s.com2.z0.glb.qiniucdn.com/activityImg_1_885E76C7-7EA0-423D-B029-2085C0F769E6", @"isFavo" : @NO};
    NSDictionary *dictC = @{@"name" : @"黄浦江浮潜", @"content": @"黄浦江里洗个澡，黄浦江里洗个澡，黄浦江里洗个澡，黄浦江里洗个澡", @"like" : @37, @"unlike" : @1, @"imgURL" : @"http://7u2h3s.com2.z0.glb.qiniucdn.com/activityImg_3_2ADCF0CE-0A2F-46F0-869E-7E1BCAF455C1", @"isFavo" : @NO};
    */
    
    //_arr = [NSMutableArray new];
    
   // NSMutableArray *array = [NSMutableArray arrayWithObjects:dictA, dictB, dictC, nil];
   /* for (NSDictionary *dict in array) {
        
        //用ActivityModel类中定义的初始化方法initWithDictionary：将遍历得来的字典dict转换为ActivityModel对象
        ActivityModel *activityModel = [[ActivityModel alloc]initWithDictionary:dict];
    
        //将上述实例化好的activityModel对象插入_arr数组中
        [_arr addObject:activityModel];
        
    }*/
       if (!isLoading) {
        isLoading = YES;
        //在这里开启一个真实的网络请求
        //设置接口地址
        NSString *request = @"/event/list";
        //设置接口入参
        NSDictionary *parameter = @{@"page" : @(page), @"perPage" : @(perPage)};
        //开始请求
        [RequestAPI requestURL:request withParameters:parameter andHeader:nil byMethod:kGet andSerializer:kForm success:^(id responseObject) {
            //成功以后要做的事情，在此处执行
            NSLog(@"responseObject = %@", responseObject);
            [self endAnimation];
            if ([responseObject[@"resultFlag"] integerValue] == 8001){
                //业务逻辑成功的情况下
                NSDictionary *result = responseObject[@"result"];
                NSArray *models = result[@"models"];
                NSDictionary *pagingInfo = result[@"pagingInfo"];
                totalPage = [pagingInfo[@"totalPage"] integerValue];
                if (page == 1) {
                    //清空数组
                    [_arr removeAllObjects];
                }
                for (NSDictionary *dict in models) {
                    //用ActivityModel类中定义的初始化方法initWithDictionary：将遍历得来的字典dict转换为ActivityModel对象
                    ActivityModel *activityModel = [[ActivityModel alloc]initWithDictionary:dict];
                    //将上述实例化好的activityModel对象插入_arr数组中
                    [_arr addObject:activityModel];
                }
                //刷新表格（重载数据）
                [_activityTableView reloadData];
            } else{
                //业务逻辑失败的情况下
                NSString *errorMsg = [ErrorHandler getProperErrorString:[responseObject[@"resultFlag"] integerValue]];
                [Utilities popUpAlertViewWithMsg:errorMsg andTitle:nil onView:self];
            }
        } failure:^(NSInteger statusCode, NSError *error) {
            //失败以后要做的事情，在此处执行
            NSLog(@"statusCode = %ld", (long)statusCode);
            [self endAnimation];
            [Utilities popUpAlertViewWithMsg:@"请保存网络连接畅通" andTitle:nil onView:self];
        }];

    }
   }
//这个方法处理网络请求完成后，所有不同的动画终止
- (void)endAnimation {
    isLoading = NO;
    [_aiv stopAnimating];
    [self end];

}

//设置表格视图中有多少组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//设置表格视图中每一组有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arr.count;
}

//设置当一个细胞将要出现的时候也要做的事情
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //判断是不是最后一行细胞将要出现
    if (indexPath.row == _arr.count -1) {
        //判断是否有下一页存在
        if (page <totalPage) {
            //在这里执行上拉翻页的数据操作
            page ++;
            [self networkRequest];
        }
    }
}


//设置每一组中每一行的cell（细胞）长什么样
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //根据某个具体名字找到该名字在页面上对应的细胞
    ActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityCell" forIndexPath:indexPath];
    //根据当前正在渲染的细胞的行号，从对应的数组中拿到这一行所匹配的活动字典
    ActivityModel *activity = _arr[indexPath.row];
    
    //将http请求的字符串转换为NSURL
    NSURL *URL = [NSURL URLWithString:activity.imgUrl];
    //依靠SDWebImage来异步地下载一张远程路径下的图片并三级缓存在项目中，同时为下载的时间周期过程中设置一张临时占位图
    [cell.activityImageView sd_setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"1"]];
    //将URL给NSData(下载)
   // NSData *data = [NSData dataWithContentsOfURL:URL];
    //加载图片
    //cell.activityImageView.image = [UIImage imageWithData:data];
    //给图片添加单击手势
    [self addTapGrstureRecognizer:cell.activityImageView];
    
    
    cell.activityNameLabel.text = activity.name;
    cell.activityInfoLabel.text = activity.content;
    cell.activityLikeLabel.text = [NSString stringWithFormat:@"顶：%ld", (long)activity.reliableNumber];
    cell.activityUnLikeLabel.text = [NSString stringWithFormat:@"踩 %ld", (long)activity.unReliableNumber];
    //给一行的收藏按钮打上下标，用来区分它是哪一行的按钮
    cell.favoBtn.tag = 100000 + indexPath.row;
    
    //根据isFavo的值来判断按钮的标题是什么
    //NSString *title = activity.isFavo ? @"取消收藏" : @"收藏";
    
    [cell.favoBtn setTitle:activity.isFavo ? @"取消收藏" : @"收藏" forState:UIControlStateNormal];
    
    [self addlongPress:cell];
    
 /*   if(activity.isFavo){
        cell.favoBtn.titleLabel.text = @"取消收藏";
    }else{
        cell.favoBtn.titleLabel.text = @"收藏";
    }
    */
    
 
    /*
    //判断当前正在渲染的cell（细胞）属于第几行
    if(indexPath.row == 0){
        //第一行的情况下
        //修改图片视图中图片的内容
        cell.activityImageView.image =[UIImage imageNamed:@"123"];
        //修改标签中文字的内容
        cell.activityNameLabel.text = @"环太湖骑行";
        cell.activityInfoLabel.text = @"从无锡滨湖区到雪浪街道太湖边出发，往东绕过苏州、嘉兴、湖州、宜兴，返回无锡";
        cell.activityLikeLabel.text = @"顶:80";
        cell.activityUnLikeLabel.text = @"踩:8";
        
    }else{
       
        //修改图片视图中图片的内容
        cell.activityImageView.image =[UIImage imageNamed:@"1"];
        //修改标签中文字的内容
        cell.activityNameLabel.text = @"啊太湖骑行";
        cell.activityInfoLabel.text = @"往东绕过苏州、嘉兴、湖州、宜兴，返回无锡从无锡滨湖区到雪浪街道太湖边出发，";
        cell.activityLikeLabel.text = @"顶:80123";
        cell.activityUnLikeLabel.text = @"踩:3458";
      
    }
*/
    return cell;
}

//添加一个长按手势事件
- (void)addlongPress:(UITableViewCell *)cell{
    //初始化一个长按手势，设置响应的事件为choose:
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(choose:)];
    //设置长按手势响应的时间
    longPress.minimumPressDuration = 1.5;
    //将手势添加给cell
    [cell addGestureRecognizer:longPress];
    
}

//添加单击手势事件
- (void)addTapGrstureRecognizer: (id)any{
    //初始化一个单击手势，设置响应的事件为tapClick:
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    //将手势添加给入参
    [any addGestureRecognizer:tap];
}

//单击手势响应事件
- (void)tapClick: (UITapGestureRecognizer *)tap{
    
    if(tap.state == UIGestureRecognizerStateRecognized){
    
    //NSLog(@"图片被单击了");
    //拿到单击手势在_activityTableView中的位置
    CGPoint location = [tap locationInView:_activityTableView];
    //通过上述的点拿到在_activityTableView对应的indexPath
    NSIndexPath *indexPath = [_activityTableView indexPathForRowAtPoint:location];
    //防范
    if (_arr != nil && _arr.count !=0){
        ActivityModel *activity = _arr[indexPath.row];
        //设置大图片的位置大小
        _zoomIV = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
        //用户交互启用
        _zoomIV.userInteractionEnabled = YES;
        _zoomIV.backgroundColor = [UIColor blackColor];
        //_zoomIV.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:activity.imgUrl]]];
        [_zoomIV sd_setImageWithURL:[NSURL URLWithString:activity.imgUrl] placeholderImage:[UIImage imageNamed:@"1"]];
        //设置图片的内容模式
        _zoomIV.contentMode = UIViewContentModeScaleAspectFit;
        //获得窗口实例，并将大图放置到窗口实例上，根据苹果规则，后添加的控件会覆盖前添加的控件。
        [[UIApplication sharedApplication].keyWindow addSubview:_zoomIV];
        UITapGestureRecognizer *zoomIVTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomTap:)];
        [_zoomIV addGestureRecognizer:zoomIVTap];
    
    }
    }
}

- (void)zoomTap: (UITapGestureRecognizer *)tap{
     if(tap.state == UIGestureRecognizerStateRecognized){
         //把大图本身的东西扔掉（大图的手势）
         [_zoomIV removeGestureRecognizer:tap];
         //把自己从父级视图中移除
         [_zoomIV removeFromSuperview];
         //彻底消失（这样就不会造成内存的滥用）
         _zoomIV =nil;

}

}
//长按手势响应事件
- (void)choose:(UILongPressGestureRecognizer *)longPress{
    //判断手势的状态（长按手势有时间间隔，对应的会有开始和结束两种状态）
    if(longPress.state==UIGestureRecognizerStateBegan){
        //        NSLog(@"长按了");
        //拿到长按手势在_activityTableView中的位置
        CGPoint location=[longPress locationInView:_activityTableView];
        //通过上述的点拿到在_activityTableView对应的indexPath
        NSIndexPath *indexPath=[_activityTableView indexPathForRowAtPoint:location];
        //防范 防范 防范
        if(_arr !=nil && _arr.count !=0){
            //根据行号拿到数组中对应的数据
            ActivityModel *activity = _arr[indexPath.row];
            UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"复制操作" message:@"复制活动名称或者内容" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *actionA=[UIAlertAction actionWithTitle:@"复制活动名称" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //创建复制板
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                //将活动名称复制
                [pasteboard setString:activity.name];
                NSLog(@"复制内容：%@",pasteboard.string);
            }];
            UIAlertAction *actionB=[UIAlertAction actionWithTitle:@"复制活动内容" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                [pasteboard setString:activity.content];
                NSLog(@"%@",pasteboard.string);
            }];
            UIAlertAction *actionC=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:actionA];
            [alert addAction:actionB];
            [alert addAction:actionC];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    //    }else if(longPress.state==UIGestureRecognizerStateEnded){
    //        NSLog(@"结束长按了");    }
    
}
    
//设置每一组中每一行cell（细胞）的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //获取三要素（计算文字高度的三要素）
    //1、文字内容
    ActivityModel *activity = _arr[indexPath.row];
    NSString *activityContent = activity.content;
    //2、字体大小
    ActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityCell"];
    UIFont *font = cell.activityInfoLabel.font;
    //3、宽度尺寸
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 30;
    CGSize size = CGSizeMake(width ,1000);
    //根据三元素计算尺寸
   CGFloat height = [activityContent boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:font} context:nil].size.height;
    //活动内容标签的原点Y轴位置加上活动内容标签根据文字自适应大小后获得的高度 + 活动内容标签距离细胞底部的间距
    
    return cell.activityInfoLabel.frame.origin.y + height +10;
}

//设置每一组中每一行的cell（细胞）被点击以后要做的事情
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //判断当前tableView是否为_activityTableView(这个条件判断常用在一个页面中有多个tableView的时候)
    if ([tableView isEqual:_activityTableView]){
        //取消选中
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    

}

/*- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
}*/

- (IBAction)favoAction:(UIButton *)sender forEvent:(UIEvent *)event {
    
    if(_arr != nil && _arr.count !=0) {
    //通过按钮的下标值减去100000拿到行号，再通过行号拿到对应的数据模型。
    ActivityModel *activity = _arr[sender.tag - 100000];
    
        NSString *message = activity.isFavo ? @"是否取消收藏该活动?" : @"是否收藏该活动？";
        
    //创建弹出框，标题为@“提示”，内容为@“是否收藏该活动？”
    UIAlertController *alert =  [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    //创建取消按钮
    UIAlertAction *actionA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    //创建确定按钮
    UIAlertAction *actionB = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (activity.isFavo){
            activity.isFavo = NO;
        }else{
            activity.isFavo = YES;
        }
        
        [self.activityTableView reloadData];
    }];
    //将按钮添加到弹出框中，（添加按钮的顺序决定了按钮的排版:从左到右；从上往下，取消风格的按钮会在最左边）
    [alert addAction:actionA];
    [alert addAction:actionB];
    //用presentViewController的方法，以model的方式显示另一个页面（显示弹出框）
    [self presentViewController:alert animated:YES completion:^{
    }];
    
    }
}

- (IBAction)searchAction:(UIBarButtonItem *)sender {
    //1、获得要跳转的页面的实例
    IssueViewController *searchVc = [Utilities getStoryboardInstance:@"Issue" byIdentity:@"Issue"];
    //2、用某种方式跳转到上述页面（这里用modal的方式跳转）
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:searchVc];
    [self presentViewController:nc animated:YES completion:nil];
    
    //纯代码push的跳转
    //[self.navigationController pushViewController:searchVc animated:YES];
}

//当某个页面跳转行为将要发生的时候
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"List2Detail"]) {
        //当从列表页到详情页的这个跳转要发生的时候
        //1、获取要传递到下一页去的数据
        NSIndexPath *indexPath = [_activityTableView indexPathForSelectedRow];
        ActivityModel *activity = _arr[indexPath.row];
        //2、获取下一页这个实例
        DetailViewController *detailVC = segue.destinationViewController;
        //3、把数据给下一页预备好的接收容器
        detailVC.activity = activity;
        
    }
}

@end
