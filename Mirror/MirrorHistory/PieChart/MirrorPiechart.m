//
//  MirrorPiechart.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/9.
//

#import "MirrorPiechart.h"
#import "MirrorDataModel.h"
#import "MirrorStorage.h"
#import "SliceLayer.h"
#import "MirrorTool.h"
#import <Masonry/Masonry.h>
#import "MirrorMacro.h"
#import "MirrorTimeText.h"

// https://blog.csdn.net/lerryteng/article/details/51564197

@interface MirrorPiechart ()

@property (nonatomic, strong) NSMutableArray *sliceLayerArray;
@property (nonatomic, strong) NSMutableArray<MirrorDataModel *> *data;
@property (nonatomic, assign) BOOL enableInteractive;

@end

@implementation MirrorPiechart


- (instancetype)initWithData:(NSMutableArray<MirrorDataModel *> *)data width:(CGFloat)width enableInteractive:(BOOL)enableInteractive
{
    self = [super init];
    if (self) {
        self.sliceLayerArray = @[].mutableCopy;
        self.data = data;
        self.enableInteractive = enableInteractive;
        [self drawPiechartWithWidth:(CGFloat)width];
    }
    return self;
}

- (void)updateWithData:(NSMutableArray<MirrorDataModel *> *)data width:(CGFloat)width enableInteractive:(BOOL)enableInteractive
{
    [[self.layer.sublayers copy] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CALayer * subLayer = obj;
        [subLayer removeFromSuperlayer];
    }];
    self.sliceLayerArray = @[].mutableCopy;
    self.data = data;
    self.enableInteractive = enableInteractive;
    [self drawPiechartWithWidth:(CGFloat)width];
}

- (void)drawPiechartWithWidth:(CGFloat)width
{
    CGFloat startAngle = 1.5 * M_PI; // 0点方向开始 角度范围将被限制在[1.5 * M_PI, 3.5 * M_PI]
    CGFloat endAngle = 0;
    NSMutableArray *percentages = [NSMutableArray new];
    NSMutableArray *colors = [NSMutableArray new];
    NSMutableArray *texts = [NSMutableArray new];
    long totalTime = 0;
    for (int i=0; i<self.data.count; i++) {
        MirrorDataModel *task = self.data[i];
        [percentages addObject:@([MirrorTool getTotalTimeOfPeriods:task.periods])];
        totalTime = totalTime + [MirrorTool getTotalTimeOfPeriods:task.periods];
        colors[i] = @(task.color);
        NSString *hourText = [MirrorTimeText XdXhXmXsShort:[MirrorTool getTotalTimeOfPeriods:task.periods]];
        texts[i] = hourText;
    }

    for (int i=0; i<percentages.count; i++) {
        percentages[i] = totalTime ? @([percentages[i] doubleValue]/(double)totalTime) : @0;
        NSString *percentageText =  [NSString stringWithFormat:@"(%1.f%%)", [percentages[i] floatValue]  * 100];
        texts[i] = [texts[i] stringByAppendingString: percentageText];
    }
    for (int i=0; i<percentages.count; i++) {
        CGFloat percentage = [percentages[i] floatValue];
        CGFloat angle = percentage * M_PI * 2;
        endAngle = angle + startAngle;
        
        SliceLayer *sliceLayer = [[SliceLayer alloc] init];
        sliceLayer.startAngle = startAngle;
        sliceLayer.endAngle = endAngle;
        sliceLayer.radius = width/2;
        sliceLayer.centerPoint = CGPointMake(width/2, width/2);
        sliceLayer.pieWidth = width;
        sliceLayer.colorType = [colors[i] intValue];
        sliceLayer.text = texts[i];
        sliceLayer.tag = i;
        [sliceLayer create];
        [self.layer addSublayer:sliceLayer];
        [self.sliceLayerArray addObject:sliceLayer];

        startAngle = endAngle;
    }

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (!self.enableInteractive) return;
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    for (int i=0; i<self.sliceLayerArray.count; i++) {
        SliceLayer *slice = self.sliceLayerArray[i];
        if (CGPathContainsPoint(slice.path, 0, touchPoint, YES) && !slice.selected) {
            slice.selected = YES;
        } else {
            slice.selected = NO;
            [slice.textLayer removeFromSuperlayer];
        }
    }
}

@end
