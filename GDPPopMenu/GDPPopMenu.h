

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GDPPopMenuDelegate <NSObject>

- (void)didClickAtIndex:(NSInteger)index;

@end

@interface GDPPopMenu : UIView

@property (nonatomic, weak) id<GDPPopMenuDelegate>           delegate;

+ (instancetype)showOnView:(UIView *)view titles:(NSArray *)titles icons:(NSArray *)icons delegate:(id<GDPPopMenuDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
