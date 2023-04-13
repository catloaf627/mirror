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

// 给定一个起始时间，取出该时间以后的信息
- (instancetype)initWithWidth:(CGFloat)width startedTime:(long)startedTime
{
    self = [super init];
    if (self) {
        self.sliceLayerArray = @[].mutableCopy;
        self.data = [self getDataWithStart:startedTime end:[[NSDate now] timeIntervalSince1970]];
        [self drawPiechartWithWidth:(CGFloat)width];
    }
    return self;
}

- (NSMutableArray<MirrorDataModel *> *)getDataWithStart:(long)startTime end:(long)endTime
{
    /* 所有的情况：
                        _________________________________
               _____   |   _____      _____      _____   |   _____
            __|_____|__|__|_____|____|_____|____|_____|__|__|_____|__
                             !                     !
                         start time             end time
    
    */
    BOOL printDetailsToDebug = NO; // debug用
    NSMutableArray<MirrorDataModel *> *targetTasks = [NSMutableArray<MirrorDataModel *> new];
    NSMutableArray<MirrorDataModel *> *allTasks = [MirrorDataManager allTasks];
    if (printDetailsToDebug) NSLog(@"数据库里的task个数 %@", @(allTasks.count));
    for (int taskIndex=0; taskIndex<allTasks.count; taskIndex++) {
        MirrorDataModel *task = allTasks[taskIndex];
        [MirrorTool timeFromTimestamp:startTime printTimeStamp:YES];
        [MirrorTool timeFromTimestamp:endTime printTimeStamp:YES];
        MirrorDataModel *targetTask = [[MirrorDataModel alloc] initWithTitle:task.taskName createdTime:task.createdTime colorType:task.color isArchived:task.isArchived periods:[NSMutableArray new] isAddTask:NO];
        BOOL targetTaskIsEmpty = YES;
        for (int periodIndex=0; periodIndex<task.periods.count; periodIndex++) {
            NSMutableArray *period = task.periods[periodIndex];
            if (printDetailsToDebug) {
                NSLog(@"第%@个task%@的第%@个period，[%@,%@]，选取的时间段[%@,%@]",@(taskIndex), [UIColor getEmoji:task.color], @(periodIndex), period.count>0 ? period[0] : @"?", period.count>1 ? period[1] : @"?", @(startTime), @(endTime));
            }
            if (period.count != 2) {
                if (printDetailsToDebug) NSLog(@"✖️正在计时中，不管");
                continue; // 正在计时中，不管
            } if ([period[1] longValue] < startTime) {
                if (printDetailsToDebug) NSLog(@"✖️完整地发生在start time之前，不管");
                // 完整地发生在start time之前，不管
            } else if ([period[0] longValue] < startTime &&  startTime < [period[1] longValue]) {
                if (printDetailsToDebug) NSLog(@"✔️跨越了start time，取后半段");
                targetTaskIsEmpty = NO;// 跨越了start time，取后半段
                [targetTask.periods addObject:[@[@(startTime), period[1]] mutableCopy]];
            } else if (startTime < [period[0] longValue] && [period[1] longValue] < endTime) {
                if (printDetailsToDebug) NSLog(@"✔️完整地发生在start time和end time中间");
                targetTaskIsEmpty = NO;// 完整地发生在start time和end time中间
                [targetTask.periods addObject:[@[period[0], period[1]] mutableCopy]];
            } else if ([period[0] longValue] < endTime && endTime < [period[1] longValue]) {
                if (printDetailsToDebug) NSLog(@"✔️跨越了end time，取前半段");
                targetTaskIsEmpty = NO;// 跨越了end time，取前半段
                [targetTask.periods addObject:[@[ period[0], @(endTime)] mutableCopy]];
            } else if (endTime < [period[0] longValue]) {
                if (printDetailsToDebug) NSLog(@"✖️完整地发生在end time之后，不管");
                // 完整地发生在end time之后，不管
            } else if ([period[0] longValue] < startTime && endTime < [period[1] longValue]) {
                if (printDetailsToDebug) NSLog(@"✖️囊括了整个starttime到endtime");
                targetTaskIsEmpty = NO;// 囊括了整个starttime到endtime
                [targetTask.periods addObject:[@[@(startTime), @(endTime)] mutableCopy]];
            }
            
        }
        if (!targetTaskIsEmpty) {
            if (printDetailsToDebug) NSLog(@"这个task%@里有目标时间段内的periods，已经取出", [UIColor getEmoji:task.color]);
            [targetTasks addObject:targetTask];
        }
    }
    return targetTasks;
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

@end
