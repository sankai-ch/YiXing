//
//  CityTableViewController.m
//  ios_3_Acti
//
//  Created by admin on 2017/8/19.
//  Copyright © 2017年 Education. All rights reserved.
//

#import "CityTableViewController.h"
#import <CoreLocation/CoreLocation.h>
@interface CityTableViewController ()<CLLocationManagerDelegate> {
    BOOL firstVisit;
}
@property (strong, nonatomic) NSDictionary *cities;
@property (strong, nonatomic) NSArray *keys;
- (IBAction)cityAction:(UIButton *)sender forEvent:(UIEvent *)event;
@property (weak, nonatomic) IBOutlet UIButton *cityBtn;
@property (strong, nonatomic) CLLocationManager *locMgr;
@property (strong, nonatomic) CLLocation *location;
@end

@implementation CityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self naviConfig];
    [self dataInitialize];
    [self uiLayout];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [_locMgr stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//这个方法专门做导航条的控制
- (void)naviConfig{
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


- (void)dataInitialize {
    firstVisit = YES;
    //创建文件管理器
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    //获取要读取的文件路径
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Cities" ofType:@"plist"];
    //判断路径下是否存在文件
    if ([fileMgr fileExistsAtPath:filePath]) {
        //将文件内容读取为对应的格式
        NSDictionary *fileContent = [NSDictionary dictionaryWithContentsOfFile:filePath];
        //判断读取到的内容是否存在（判断文件是否损坏）
        if (fileContent) {
            NSLog(@"filecontent = %@",fileContent);
            //NSLog(@"all vla = %@",fileContent.allValues);
            _cities = fileContent;
            //提取字典中所有的键
            NSArray *rawKeys = [fileContent allKeys];
            //NSLog(@"%@",rawKeys);
            //根据拼音首字母进行能够识别多音字的升序排序
            _keys = [rawKeys sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
            
        }
    }
}

- (void)uiLayout {
    if (![[[StorageMgr singletonStorageMgr] objectForKey:@"locDict"] isKindOfClass:[NSNull class]]) {
        if ([[StorageMgr singletonStorageMgr] objectForKey:@"locDict"] != nil) {
            //已经获得了定位，将定位到的城市显示在按钮上
            [_cityBtn setTitle:[[StorageMgr singletonStorageMgr] objectForKey:@"locDict"] forState:UIControlStateNormal];
            _cityBtn.enabled = YES;
            return;
        }
    }
    //当还没有获取定位的情况下，去执行定位
    [self locationStart];
}

- (void)locationStart {
    //初始化
    _locMgr = [CLLocationManager new];
    //签协议
    _locMgr.delegate = self;
    //识别定位到的设备位移多少距离进行一次识别
    _locMgr.distanceFilter = kCLDistanceFilterNone;
    //设置地球分割成边长多少精度的方块
    _locMgr.desiredAccuracy = kCLLocationAccuracyBest;
    //开始定位
    [_locMgr startUpdatingLocation];
}


//用model的方式返回上一页
- (void)backAction{
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];//用push返回上一页
}

#pragma mark - Table view data source
//组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return _keys.count;
}
//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //获取当前正在渲染的组的名称
    NSString *key = _keys[section];
    //根据key值拿到数组
    NSArray *sectionCity = _cities[key];
    //
    
    
    return sectionCity.count;
}

//表格样式
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityCell" forIndexPath:indexPath];
    NSString *key = _keys[indexPath.section];
    //根据key值拿到数组
    NSArray *sectionCity = _cities[key];
    NSDictionary *city = sectionCity[indexPath.row];
    cell.textLabel.text = city[@"name"];
    return cell;
}
//设置每组的标题文字
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return _keys[section];
}

//设置section header的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.f;
}

//设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.f;
}

//选中后的操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *key = _keys[indexPath.section];
    //根据key值拿到数组
    NSArray *sectionCity = _cities[key];
    NSDictionary *city = sectionCity[indexPath.row];
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:[NSNotification notificationWithName:@"ResetHome" object:city[@"name"]] waitUntilDone:YES];
    //跳转
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
//设置右侧快捷键栏
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _keys;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - btnAction

- (IBAction)cityAction:(UIButton *)sender forEvent:(UIEvent *)event {
    
    NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
    //A
    //[noteCenter postNotificationName:@"ResetHome" object:nil];
    //B
    NSNotification *note = [NSNotification notificationWithName:@"ResetHome" object:[[StorageMgr singletonStorageMgr] objectForKey:@"locDict"]];
    //直接执行
    //[noteCenter postNotification:note];
    //结合线程的通知（表示先让通知接收者完成它收到的通知后要做的事以后再执行别的任务）
    [noteCenter performSelectorOnMainThread:@selector(postNotification:) withObject:note waitUntilDone:YES];
    //回到上一页
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - loction

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
                [[StorageMgr singletonStorageMgr] removeObjectForKey:@"locDict"];
                //将定位到的城市保存进单例化全局变量
                [[StorageMgr singletonStorageMgr] addKey:@"locDict" andValue:cityStr];
                NSLog(@"city = %@",cityStr);
                //修改标题
                [_cityBtn setTitle:cityStr forState:UIControlStateNormal];
                _cityBtn.enabled = YES;
                
            }
        }];
        //三秒后关掉开关
        [_locMgr stopUpdatingLocation];
    });
}


@end
