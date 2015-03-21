
#import "ProgressBar.h"
#import <QuartzCore/QuartzCore.h>

@interface ProgressBar()
@property (nonatomic, weak) CAShapeLayer *progressLayer;
@property (nonatomic, weak) CAShapeLayer *trackLayer;
@property (nonatomic, weak) CAShapeLayer *clickLayer;
@property(nonatomic,retain)NSMutableArray *circlesArray;
@property(nonatomic,retain)NSMutableArray *circlesPoint;
@property(nonatomic,assign)int preIndex;
@end

void (^nowExecute)(int index);

@implementation ProgressBar

-(id)initWithFrame:(CGRect)frame {
    self=[super initWithFrame:frame];
    
    CAShapeLayer *trackLayer=[[CAShapeLayer alloc]init];
    [self.layer addSublayer:trackLayer];
    self.trackLayer=trackLayer;
    self.trackLayer.fillColor=[UIColor clearColor].CGColor;
    
    CAShapeLayer *progressLayer=[[CAShapeLayer alloc]init];
    [self.layer addSublayer:progressLayer];
    self.progressLayer=progressLayer;
    self.progressLayer.fillColor=[UIColor clearColor].CGColor;
    
    _progressColor=[UIColor redColor].CGColor;
    _trackColor=[UIColor grayColor].CGColor;
    
    _strokeWith=4.0;
    
//    self.layer.borderColor = UIColor.blackColor.CGColor;
//    self.layer.borderWidth = 1.0f;
    
    [self setTrack];
    
    _smallRadius=3.5;//小圆半径
    _bigRadius=5.5;//大圆半径
    
    self.preIndex=0;
    _currentIndex=0;
    
    
    
    self.counts=5;//设置小球个数，初始化所有小球
    
    UITapGestureRecognizer *gest=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapEvent:)];
    [self addGestureRecognizer:gest];

    return self;
}
-(void) setUpdateIndex:(void (^)(int index)) carryOut //更新外部
{
    nowExecute=[carryOut copy];
}
//------------------------触摸
-(void)tapEvent:(UITapGestureRecognizer *)gesture {
    CGPoint touchPoint=[gesture locationInView:self];
    CGFloat x=touchPoint.x;
    CGFloat y=touchPoint.y;
    CGFloat smallY=self.frame.size.height/2-self.bigRadius/2.0;
    CGFloat bigY=self.frame.size.height/2+self.bigRadius/2.0;
    if (y>smallY&&y<bigY) {
        int clickIndex=[self isOnSomeX:x];
        if (clickIndex>=0&&clickIndex<[self.circlesPoint count]) {
             [self setCurrentIndex:clickIndex];
            nowExecute(clickIndex);
        }
    }
}
-(int)isOnSomeX:(CGFloat)cx {
    for (int i=0; i<[self.circlesPoint count]; i++) {
        CGPoint center=CGPointFromString(self.circlesPoint[i]);
        CGFloat smallX=center.x-self.bigRadius/2.0;
        CGFloat bigX=center.x+self.bigRadius/2.0;
        if (cx > smallX && cx < bigX) {
            return i;
        }
    }
    return -1;
}
-(CAShapeLayer *)drawCircle:(CAShapeLayer *)circleLayer CenterRect:(CGPoint)point radius:(CGFloat)radius{//画园点
    
    UIBezierPath *path=[UIBezierPath bezierPathWithArcCenter:point radius:radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    circleLayer.path=path.CGPath;
    return circleLayer;
}
-(void)setTrack {//设置背景轨迹
    CGFloat height=self.frame.size.height;
    CGFloat top=height/2.0;
//    NSLog(@"%f--%f==%f",self.frame.size.height,self.strokeWith,top);
    
    UIBezierPath *path=[UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, top)];
    [path addLineToPoint:CGPointMake(self.frame.size.width, top)];
    self.trackLayer.lineWidth=self.strokeWith;
    self.trackLayer.strokeColor=_trackColor;
    self.trackLayer.path=path.CGPath;
}
-(void)setProgress {//设置进度轨迹
    UIBezierPath *path=[UIBezierPath bezierPath];
    CGFloat top=self.frame.size.height/2.0;
    [path moveToPoint:CGPointMake(0, top)];
//    CGFloat left=self.frame.size.width/(self.counts-1)*self.currentIndex;
    [path addLineToPoint:CGPointMake(self.frame.size.width, top)];
    self.progressLayer.lineWidth=self.strokeWith;
    self.progressLayer.strokeColor=_progressColor;
    self.progressLayer.path=path.CGPath;
}
-(void)setCurrentIndex:(int)currentIndex {//设置当前选中的小球
    self.preIndex=self.currentIndex;
    _currentIndex=currentIndex;
    NSLog(@"preIndex=%d,currentIndex=%d---_cur=%d",self.preIndex,currentIndex,_currentIndex);
    
    [self updateCircles];
    [self moveProgress];
}
-(void)updateCircles {//更新小球
    CGFloat radius=self.smallRadius;
    for (int i=0; i<self.counts; i++) {
        CAShapeLayer *circleLayer=self.circlesArray[i];
        if (i==self.currentIndex) {
            radius=self.bigRadius;
           
        }else {
            radius=self.smallRadius;
        }
        
        if (i<=self.currentIndex) {
            circleLayer.fillColor=self.progressColor;
        }else {
            circleLayer.fillColor=self.trackColor;
        }
        
        CGFloat  left=(self.frame.size.width-self.bigRadius)/(self.counts-1)*i+self.bigRadius/2.0;
        CGPoint center=CGPointMake(left, self.frame.size.height/2.0);
        circleLayer=[self drawCircle:circleLayer CenterRect:center radius:radius];
    }
    
}
-(void)moveProgress {
    CGFloat count=[self.circlesArray count]-1;
    float fromValue=self.preIndex/count;
    float toValue=self.currentIndex/count;
    
    self.progressLayer.strokeEnd=toValue;
    CABasicAnimation *anima=nil;
    anima=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    anima.duration=3;
    anima.repeatCount=0;
    anima.removedOnCompletion=NO;
    anima.fillMode=kCAFillModeBackwards;
    
    anima.fromValue=[NSNumber numberWithFloat:fromValue];
    anima.toValue=[NSNumber numberWithFloat:toValue];

//    anima.autoreverses=YES;
    anima.delegate=self;
    [self.progressLayer addAnimation:anima forKey:@"stroke"];
    
}
-(void)setCounts:(int)counts{//最初的小球初始化，设置小球的
    _counts=counts;
    self.circlesArray=[[NSMutableArray alloc]init];
    self.circlesPoint=[[NSMutableArray alloc]init];
    for (int i=0; i<self.counts; i++) {//创建四个小圆
        CAShapeLayer *circleLayer=[[CAShapeLayer alloc]init];
        CGFloat  left=(self.frame.size.width-self.bigRadius)/(self.counts-1)*i+self.bigRadius/2.0;
        CGPoint center= CGPointMake(left, self.frame.size.height/2.0);//求出小圆圆心
        [self.circlesPoint addObject:NSStringFromCGPoint(center)];
        CGFloat radius=self.smallRadius;
        if (i==0) {
            circleLayer.fillColor=self.progressColor;
            radius=self.bigRadius;
        }else {radius=self.smallRadius;}
        circleLayer=[self drawCircle:circleLayer CenterRect:center radius:radius];
        [self.layer addSublayer:circleLayer];
        [self.circlesArray addObject:circleLayer];//将小圆存入数组
    }
    [self setProgress];
    [self setCurrentIndex:0];
}
-(void)setTrackColor:(CGColorRef)trackColor {
    _trackColor=trackColor;
    self.trackLayer.strokeColor=trackColor;
    [self setTrack];
}
-(void)setProgressColor:(CGColorRef)progressColor{
    _progressColor=progressColor;
}
@end
