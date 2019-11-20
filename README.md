# GDPPopMenu
列表选择弹框

## Use
下载GDPPopMenu框架,
把GDPPopMenu.h/GDPPopMenu.m文件拷贝到项目中.
导入头文件#import "GDPPopMenu.h".

## 创建方法
```
- (void)ButtonClick {
    [GDPPopMenu showOnView:self.button titles:@[@"今天", @"最近三天", @"最近一周",@"最近一月",@"最近半年"] icons:@[] delegate:self];
}
 
```

## 效果见效果图.png




## License

GDPPopMenu is released under a MIT License. See LICENSE file for details.

