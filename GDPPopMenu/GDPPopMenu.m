

#import "GDPPopMenu.h"

#define kMenuMaxWith  150
#define kMenuMaxHeight 200
#define kArrowWidth  15
#define kArrowHeight  10
#define kCornerRadius  5
#define kMenuCellHeight  44
#define kMenuMinWidth 120
#define kMenuMargin 5
#define kMenuMaxShowCellCount 4

@interface GDPPopMenu () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)   UITableView                 *menuTableView;
@property (nonatomic, strong)   UIView                      *bgView;

@property (nonatomic, strong)   NSMutableArray              *titleArray;
@property (nonatomic, strong)   NSMutableArray              *iconArray;

@property (nonatomic, assign)   CGFloat                     borderWidth;
@property (nonatomic, assign)   CGFloat                     arrowPosition;
@property (nonatomic, assign)   CGPoint                     touchPoint;
@property (nonatomic, assign)   CGFloat                     popViewWidth;

@end

@implementation GDPPopMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowRadius = 2.0;
    self.layer.anchorPoint = CGPointMake(1, 0);
}

+ (instancetype)showOnView:(UIView *)view titles:(NSArray *)titles icons:(NSArray *)icons delegate:(id<GDPPopMenuDelegate>)delegate {
    if (titles.count <= 0) {
        return nil;
    }
    
    UIWindow *keyWindow;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13) {
        keyWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    } else {
        keyWindow = [UIApplication sharedApplication].keyWindow;
    }
    CGRect rectOfKeyWindow = [view convertRect:view.bounds toView:keyWindow];
    CGPoint touchPoint = CGPointMake(rectOfKeyWindow.origin.x + rectOfKeyWindow.size.width / 2, rectOfKeyWindow.origin.y + rectOfKeyWindow.size.height-2);
    
    GDPPopMenu *popMenu = [[GDPPopMenu alloc] init];
    [popMenu.titleArray removeAllObjects];
    [popMenu.titleArray addObjectsFromArray:titles];
    
    if (icons.count > 0) {
        [popMenu.iconArray removeAllObjects];
        [popMenu.iconArray addObjectsFromArray:icons];
        popMenu.popViewWidth = kMenuMaxWith;
    } else {
        popMenu.popViewWidth = kMenuMinWidth;
    }
    
    popMenu.delegate = delegate;
    popMenu.touchPoint = touchPoint;
    [popMenu layoutMenuAtPoint:touchPoint];
    [popMenu addSubview:popMenu.menuTableView];
    
    [popMenu show];
    
    return popMenu;
}

- (void)layoutMenuAtPoint:(CGPoint)point {
    CGFloat height;
    if (self.titleArray.count > kMenuMaxShowCellCount) {
        height = kMenuMaxHeight;
    } else {
        height = kMenuCellHeight * self.titleArray.count + kArrowHeight;
    }
    
    //touchPoint 靠近屏幕左右边界处理
    CGFloat frameX;
    if (point.x < (self.popViewWidth/2 + kMenuMargin)) {
        frameX = kMenuMargin;
    } else if (([UIScreen mainScreen].bounds.size.width - point.x) < (self.popViewWidth/2 + kMenuMargin)) {
        frameX = [UIScreen mainScreen].bounds.size.width - kMenuMargin - self.popViewWidth;
    } else {
        frameX = point.x - self.popViewWidth/2;
    }
    
    CGFloat anchorPointX = (point.x - frameX)/self.popViewWidth;
    self.layer.anchorPoint = CGPointMake(anchorPointX, 0);
    self.frame = CGRectMake(frameX, point.y, self.popViewWidth, height);
}

- (void)show {
    UIView *view;
    if ([self.delegate isKindOfClass:[UIViewController class]]) {
        UIViewController *vc = (UIViewController *)self.delegate;
        view = vc.view;
    } else if ([self.delegate isKindOfClass:[UIView class]]) {
        view = (UIView *)self.delegate;
    } else {
        view = [UIView new];
    }
    
    [view addSubview:self.bgView];
    [view addSubview:self];
    
    self.layer.affineTransform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration:0.25 animations:^{
        self.layer.affineTransform = CGAffineTransformMakeScale(1.0, 1.0);
        self.alpha = 1;
        self.bgView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dissmiss {
    [UIView animateWithDuration:0.25 animations:^{
        self.layer.affineTransform = CGAffineTransformMakeScale(0.1, 0.1);
        self.alpha = 0;
        self.bgView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.bgView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //利用path进行绘制三角形
    CGFloat beginX=(self.touchPoint.x-CGRectGetMinX(self.frame));
    CGFloat beginY=0;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    CGPoint topLeftArcCenter = CGPointMake(5, 15);
    CGPoint topRightArcCenter = CGPointMake(rect.size.width-5, beginY+kArrowHeight+5);
    CGPoint bottomLeftArcCenter = CGPointMake(5,CGRectGetHeight(rect)-5);
    CGPoint bottomRightArcCenter = CGPointMake(rect.size.width-5,CGRectGetHeight(rect)-5);
    
    [bezierPath moveToPoint:CGPointMake(beginX, beginY)];
    [bezierPath addLineToPoint:CGPointMake(beginX+kArrowWidth/2.0, beginY+kArrowHeight)];
    [bezierPath addLineToPoint:CGPointMake(topRightArcCenter.x, beginY+kArrowHeight)];
    [bezierPath addArcWithCenter:topRightArcCenter radius:5 startAngle:M_PI * 3 / 2 endAngle:2 * M_PI clockwise:YES];
    [bezierPath addLineToPoint:CGPointMake(rect.size.width, bottomRightArcCenter.y)];
    [bezierPath addArcWithCenter:bottomRightArcCenter radius:5 startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [bezierPath addLineToPoint:CGPointMake(bottomLeftArcCenter.x, CGRectGetHeight(rect))];
    [bezierPath addArcWithCenter:bottomLeftArcCenter radius:5 startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [bezierPath addLineToPoint:CGPointMake(0, topLeftArcCenter.y)];
    [bezierPath addArcWithCenter:topLeftArcCenter radius:5 startAngle:M_PI endAngle:M_PI * 3 / 2 clockwise:YES];
    
    [bezierPath addLineToPoint:CGPointMake(beginX-kArrowWidth/2.0, beginY+kArrowHeight)];
    
    [[UIColor whiteColor] setStroke];
    [[UIColor whiteColor]  setFill];
    [bezierPath fill];
    [bezierPath stroke];
    
}

// MARK: - Action -
- (void)touchOutSide:(UIGestureRecognizer *)recognizer {
    [self dissmiss];
}

// MARK: UITableViewDataSource && UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * identify=@"menuCell";
    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:identify];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
        cell.textLabel.font=[UIFont systemFontOfSize:15];
    }
    cell.textLabel.text=self.titleArray[indexPath.row];
    if (self.iconArray.count>0) {
//        [cell.imageView yy_setImageWithURL:[NSURL URLWithString:self.iconArray[indexPath.row]] placeholder:[UIImage imageNamed:@"placehold80x80"]];
        CGSize itemSize = CGSizeMake(20, 20);
        UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [cell.imageView.image drawInRect:imageRect];
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.delegate&& [self.delegate respondsToSelector:@selector(didClickAtIndex:)]) {
        [self.delegate didClickAtIndex:indexPath.row];
    }
    [self dissmiss];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kMenuCellHeight;
}

// MARK: - Setter -
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.menuTableView.frame = CGRectMake(_borderWidth, kArrowHeight, frame.size.width, frame.size.height-kArrowHeight);
}

// MARK: - Getter -
- (UITableView *)menuTableView {
    if (!_menuTableView) {
        _menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kArrowHeight, CGRectGetWidth(self.frame), (CGRectGetHeight(self.frame) - kArrowHeight)) style:UITableViewStylePlain];
        _menuTableView.dataSource = self;
        _menuTableView.delegate = self;
        _menuTableView.backgroundColor = [UIColor whiteColor];
        _menuTableView.layer.cornerRadius = 5;
    }
    return _menuTableView;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _bgView.backgroundColor= [[UIColor blackColor] colorWithAlphaComponent:0.1];
        _bgView.alpha = 0.0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(touchOutSide:)];
        [_bgView addGestureRecognizer:tap];
    }
    return _bgView;
}

- (NSMutableArray *)titleArray {
    if (!_titleArray) {
        _titleArray = [[NSMutableArray alloc] init];
    }
    return _titleArray;
}

- (NSMutableArray *)iconArray {
    if (!_iconArray) {
        _iconArray = [[NSMutableArray alloc] init];
    }
    return _iconArray;
}

@end
