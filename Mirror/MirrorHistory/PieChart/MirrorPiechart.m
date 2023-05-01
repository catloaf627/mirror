//
//  MirrorPiechart.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/9.
//

#import "MirrorPiechart.h"
#import "MirrorDataModel.h"
#import "MirrorDataManager.h"
#import "MirrorStorage.h"
#import "SliceLayer.h"
#import "MirrorTool.h"
#import <Masonry/Masonry.h>

// https://blog.csdn.net/lerryteng/article/details/51564197

@interface MirrorPiechart ()

@property (nonatomic, strong) NSMutableArray<MirrorDataModel *> *data;
@property (nonatomic, strong) NSMutableArray *sliceLayerArray;

@end

@implementation MirrorPiechart

- (instancetype)initTodayWithWidth:(CGFloat)width
{
    self = [super init];
    if (self) {
        self.sliceLayerArray = @[].mutableCopy;
        self.data = [MirrorDataManager getDataWithStart:[[self todayStartEndTime][0] longValue] end:[[self todayStartEndTime][1] longValue]];
        [self drawPiechartWithWidth:(CGFloat)width];
    }
    return self;
}

- (void)updateTodayWithWidth:(CGFloat)width
{
    [[self.layer.sublayers copy] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CALayer * subLayer = obj;
        [subLayer removeFromSuperlayer];

    }];
    self.sliceLayerArray = @[].mutableCopy;
    self.data = [MirrorDataManager getDataWithStart:[[self todayStartEndTime][0] longValue] end:[[self todayStartEndTime][1] longValue]];
    [self drawPiechartWithWidth:(CGFloat)width];
}

- (void)drawPiechartWithWidth:(CGFloat)width
{
    CGFloat startAngle = 1.5 * M_PI; // 0点方向开始 角度范围将被限制在[1.5 * M_PI, 3.5 * M_PI]
    CGFloat endAngle = 0;
    NSMutableArray *percentages = [NSMutableArray new];
    NSMutableArray *colors = [NSMutableArray new];
    long totalTime = 0;
    for (int i=0; i<self.data.count; i++) {
        MirrorDataModel *task = self.data[i];
        [percentages addObject:@([MirrorTool getTotalTimeOfPeriods:task.periods])];
        totalTime = totalTime + [MirrorTool getTotalTimeOfPeriods:task.periods];
        colors[i] = @(task.color);
    }
    for (int i=0; i<percentages.count; i++) {
        percentages[i] = totalTime ? @([percentages[i] doubleValue]/(double)totalTime) : @0;
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
        sliceLayer.tag = i;
        sliceLayer.fillColor = [UIColor mirrorColorNamed:[colors[i] intValue]].CGColor;
        [sliceLayer create];
        [self.layer addSublayer:sliceLayer];
        [self.sliceLayerArray addObject:sliceLayer];
        
        startAngle = endAngle;
    }

}

- (NSArray *)todayStartEndTime
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate now]];
    components.timeZone = [NSTimeZone systemTimeZone];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    long startTime = [[gregorian dateFromComponents:components] timeIntervalSince1970];
    long endTime = startTime + 86400;
    return @[@(startTime), @(endTime)];
}

@end
