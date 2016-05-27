//
//  ViewController.m
//  easyAdressPicker
//
//  Created by Ben on 16/5/27.
//  Copyright © 2016年 szd. All rights reserved.
//

#import "ViewController.h"

#define SCREEN_SIZE [UIScreen mainScreen].bounds.size

@interface ViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    UIPickerView *_pickerView;
    UIView *_view;
    
    //存放地区plist文件解析到的数据
    NSMutableArray *_rootArr;
    //所有省份数组
    NSMutableArray *_provinceArr;
    //某省的所有城市
    NSMutableArray *_cityArr;
    //某城市的所有县区
    NSMutableArray *_areaArr;
    //pickerView选择时的数组
    NSMutableArray *_selectArr;
}
//选择的省份、城市、地区字符串
@property(nonatomic,copy)NSString *provinceStr;
@property(nonatomic,copy)NSString *cityStr;
@property(nonatomic,copy)NSString *areaStr;

@property (weak, nonatomic) IBOutlet UIButton *pickAdressBtn;

@end

@implementation ViewController

//点击选择地址
- (IBAction)pickAdressClick:(id)sender {
    //动画弹出地址选择页面
    [UIView animateWithDuration:0.6 animations:^{
        _view.transform = CGAffineTransformMakeTranslation(0, -350);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _rootArr = [[NSMutableArray alloc] init];
    _provinceArr = [[NSMutableArray alloc] init];
    _cityArr = [[NSMutableArray alloc] init];
    _areaArr = [[NSMutableArray alloc] init];
    _selectArr = [[NSMutableArray alloc] init];
    //创建地址选择器
    [self createPickerView];
    //创建数据源
    [self createPickerViewDataArr];
}

-(void)createPickerView{
    //首先创建一个位于屏幕下方看不到的view
    _view = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_SIZE.height+155, SCREEN_SIZE.width, 200)];
    _view.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_view];
    
    //创建一个pickerView放到view上
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, SCREEN_SIZE.width, 170)];
    //设置pickerView代理
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    [_view addSubview:_pickerView];
    
    //创建一个按钮放在view上，用于选择完地址后确定
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor brownColor];
    button.frame = CGRectMake(0, 0, SCREEN_SIZE.width, 40);
    button.userInteractionEnabled = YES;
    [button setTitle:@"确定" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_view addSubview:button];
}
-(void)doneClick{
    //选择完成后动画隐藏pickerView
    [UIView animateWithDuration:0.6 animations:^{
        _view.transform = CGAffineTransformIdentity;
        //把选择完成的省份、城市、地区设置为btn的标题
        [_pickAdressBtn setTitle:[NSString stringWithFormat:@"%@ %@ %@",_provinceStr,_cityStr,_areaStr] forState:UIControlStateNormal];
    }];
    NSLog(@"%@ %@ %@",_provinceStr,_cityStr,_areaStr);
}
-(void)createPickerViewDataArr{
    //解析地址pist文件
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pcd" ofType:@"plist"]];
    
    _rootArr = dict[@"address"];
    
    for (NSDictionary *dict2 in _rootArr) {
        [_provinceArr addObject:dict2[@"name"]];
    }
    for (NSDictionary *dict3 in _rootArr[0][@"sub"]) {
        [_cityArr addObject:dict3[@"name"]];
    }
    NSArray *arr = _rootArr[0][@"sub"][0][@"sub"];
    [_areaArr addObjectsFromArray:arr];
    
    //初始化省市地区字符串
    _provinceStr = _provinceArr[0];
    _cityStr = _cityArr[0];
    _areaStr = _areaArr[0];
}


#pragma mark - pickerView代理方法 -

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    //返回 省份、市、地区三个分组
    return 3;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    //返回省份、市、地区每部分的个数
    switch (component) {
        case 0:
            return _provinceArr.count;
            break;
        case 1:
            return _cityArr.count;
            break;
        case 2:
            return _areaArr.count;
            break;
            
        default:
            return 0;
            break;
    }
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    //返回省份、市、地区每一行的标题
    switch (component) {
        case 0:
            return _provinceArr[row];
            break;
        case 1:
            return _cityArr[row];
            break;
        case 2:
            return _areaArr[row];
            break;
            
        default:
            return @" ";
            break;
    }
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    //选中某一省份时动画改变为其对应的市和地区，或选中某一市区时动画改变为其对应的地区
    switch (component) {
        case 0:
            _selectArr = _rootArr[row][@"sub"];
            [_cityArr removeAllObjects];
            for (NSDictionary *dict3 in _selectArr) {
                [_cityArr addObject:dict3[@"name"]];
            }
            _areaArr = _selectArr[0][@"sub"];
            [_pickerView reloadComponent:1];
            [_pickerView reloadComponent:2];
            [_pickerView selectRow:0 inComponent:1 animated:YES];
            [_pickerView selectRow:0 inComponent:2 animated:YES];
            
            //将选中的省、市、地区赋值
            _provinceStr = _rootArr[row][@"name"];
            _cityStr = _selectArr[0][@"name"];
            _areaStr = _selectArr[0][@"sub"][0];
            
            break;
            
        case 1:
            _areaArr = _selectArr[row][@"sub"];
            [_pickerView reloadComponent:2];
            [_pickerView selectRow:0 inComponent:2 animated:YES];
            
            _cityStr = _cityArr[row];
            _areaStr = _areaArr[0];
            break;
            
        case 2:
            _areaStr = _areaArr[row];
            break;
        default:
            break;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
