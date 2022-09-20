//
//  EZIoTPaintView.m
//  NetTest
//
//  Created by yuqian on 2021/12/21.
//  Copyright © 2021 com.hikvision.ezviz. All rights reserved.
//

#import "EZIoTPaintView.h"


#define PointColor [UIColor colorWithRed:0/255.0f green:191/255.0f blue:255/255.0f alpha:1.0]
#define RectColor [UIColor colorWithRed:0/255.0f green:191/255.0f blue:255/255.0f alpha:0.5]
#define PointEdge  20
#define PointCorner  10

@interface EZIoTPaintView()

@property (nonatomic,strong)CAShapeLayer *shapelayer;

@end

@implementation EZIoTPaintView

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.pointArray.count == 4)
    {
        [self.pointArray removeAllObjects];
        [self.shapelayer removeFromSuperlayer];
        for (UIView *subView in self.subviews) {
            [subView removeFromSuperview];
        }
    }
    
    if (event.type==UIEventTypeTouches) {

        UITouch *touch = [event.allTouches anyObject];

        if (touch.phase == UITouchPhaseBegan) {

            CGPoint point = [touch locationInView:self]; //返回触摸点在视图中的当前坐标
            int x = point.x;
            int y = point.y;

            NSLog(@"touch (x, y) is (%d, %d)", x, y);

            [self.pointArray addObject:NSStringFromCGPoint(point)];

            if (self.paintDidSelectedVertex) {
                self.paintDidSelectedVertex(self.pointArray);
            }
            
            [self toDrawPictureNow];
        }
    }
}

- (void)toDrawPictureNow
{
    if (self.pointArray.count > 1)
    {
         for (NSInteger i = 0; i < _pointArray.count - 1; i ++)
         {
              UIView *pointView = (UIView *)[self viewWithTag:100 + i];
              [pointView removeFromSuperview];
              pointView = nil;
        }
    }

    if(_shapelayer)
    {
        [_shapelayer removeFromSuperlayer];
        _shapelayer = nil;
    }

    //只有一个点
    if (_pointArray.count == 1) {

        CGPoint point= CGPointFromString([_pointArray objectAtIndex:0]);

        UIView *pointView = [[UIView alloc]init];

        pointView.frame = CGRectMake(0, 0, PointEdge, PointEdge);
        pointView.center = point;
        pointView.tag = 100;
        pointView.layer.cornerRadius = PointCorner;
        pointView.backgroundColor = PointColor;

        [self addSubview:pointView];
    }
    else
    {
        UIBezierPath *path = [UIBezierPath bezierPath];
        for (NSInteger i = 0; i < _pointArray.count; i++)
        {
             CGPoint point= CGPointFromString([_pointArray objectAtIndex:i]);
             if (i == 0)
             {
                 [path moveToPoint:point];
             }
             else
             {
                 [path addLineToPoint:point];
             }

             UIView *pointView = [[UIView alloc]init];

             pointView.frame = CGRectMake(0, 0, PointEdge, PointEdge);
             pointView.tag = 100 + i;
             pointView.center = point;
             pointView.layer.cornerRadius = PointCorner;
             pointView.backgroundColor = PointColor;

             [self addSubview:pointView];

             UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
             [pointView addGestureRecognizer:pan];
        }

        [path stroke];
        if (self.pointArray.count == 4) {
            [path fill];
            [path closePath];
        }

        _shapelayer = [CAShapeLayer layer];

        _shapelayer.strokeColor = [PointColor CGColor];
        _shapelayer.fillColor = self.pointArray.count == 4 ? [RectColor CGColor] : [UIColor clearColor].CGColor;
        _shapelayer.path = path.CGPath;
        [self.layer addSublayer:_shapelayer];
    }
    if (self.pointArray.count == 4) {
        NSLog(@"pointArray: %@", self.pointArray);
    }
}

/*---------------------处理移动手势--------------*/
- (void)panGestureAction:(UIPanGestureRecognizer *)gesture
{
//    CGPoint point = [gesture translationInView:gesture.view];
//    [gesture setTranslation:CGPointZero inView:gesture.view];
//    [self reloadViewWithPoint:point andItme:gesture.view.tag - 99];
}

- (void)reloadViewWithPoint:(CGPoint)itemPoint andItme:(NSInteger)itemp
{
    CGPoint orignialPoint = CGPointFromString([self.pointArray objectAtIndex:itemp - 1]);
    CGPoint desPoint = CGPointMake(orignialPoint.x + itemPoint.x, orignialPoint.y + itemPoint.y);
    NSLog(@"Finaltouch(%f, %f)", desPoint.x, desPoint.y);
    [_pointArray replaceObjectAtIndex:(itemp - 1) withObject:NSStringFromCGPoint(desPoint)];
    [self toDrawPictureNow];
}

- (NSMutableArray *)pointArray
{
    if (!_pointArray) {
        _pointArray = [NSMutableArray array];
    }
    return _pointArray;
}

@end
