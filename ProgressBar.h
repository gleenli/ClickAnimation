#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ProgressBar : UIView
@property(nonatomic)int counts;//个数
@property(nonatomic)CGColorRef trackColor;//背景颜色
@property(nonatomic)CGColorRef progressColor;//高亮的颜色
@property(nonatomic)CGFloat time;//动画时间
@property(nonatomic)CGFloat strokeWith;//线宽
@property(nonatomic)int currentIndex;//改变当前索引,从0开始
@property(nonatomic)CGFloat bigRadius;//大圆半径
@property(nonatomic)CGFloat smallRadius;//小圆半径

-(void) setUpdateIndex:(void (^)(int index)) carryOut;//更新外部
@end
