//
//  ViewController.m
//  GDPPopMenu
//
//  Created by ule on 2019/11/19.
//  Copyright © 2019 ule. All rights reserved.
//

#import "ViewController.h"
#import "GDPPopMenu.h"

@interface ViewController () <GDPPopMenuDelegate>

@property (nonatomic, strong)   UIButton           *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.button];
}

- (void)ButtonClick {
    [GDPPopMenu showOnView:self.button titles:@[@"今天", @"最近三天", @"最近一周",@"最近一月",@"最近半年"] icons:@[] delegate:self];
}

- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc] initWithFrame:CGRectMake(50, 200, 80, 40)];
        _button.backgroundColor = [UIColor lightGrayColor];
        [_button setTitle:@"点我有弹框" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [_button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_button addTarget:self action:@selector(ButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

- (void)didClickAtIndex:(NSInteger)index {
    NSLog(@"点击了第几%ld行",index);
}

@end
