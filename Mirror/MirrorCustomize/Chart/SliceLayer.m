//
//  SliceLayer.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/9.
//

#import "SliceLayer.h"
#import "UIColor+MirrorColor.h"

@implementation SliceLayer

- (void)create {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:_centerPoint];
    [path addArcWithCenter:_centerPoint radius:_radius startAngle:_startAngle endAngle:_endAngle clockwise:YES];
    [path closePath];
    self.path = path.CGPath;
    self.strokeColor = [UIColor mirrorColorNamed:MirrorColorTypeAddTaskCellBG].CGColor;
}
 
- (void)setSelected:(BOOL)selected {
    _selected = selected;
    CGPoint newCenterPoint = _centerPoint;
    if (selected) {
        newCenterPoint = CGPointMake(_centerPoint.x + cosf((_startAngle + _endAngle) / 2) * 30, _centerPoint.y + sinf((_startAngle + _endAngle) / 2) * 30);
    }
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:newCenterPoint];
    [path addArcWithCenter:newCenterPoint radius:_radius startAngle:_startAngle endAngle:_endAngle clockwise:YES];
    [path closePath];
    self.path = path.CGPath;
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"path";
    animation.toValue = path;
    animation.duration = 0.5;
    [self addAnimation:animation forKey:nil];
}


@end
