//
//  TimeTrackingLabel.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/8.
//

#import "TimeTrackingLabel.h"
#import "UIColor+MirrorColor.h"
#import "MirrorDataModel.h"
#import "MirrorStorage.h"
#import "MirrorLanguage.h"
#import "MirrorMacro.h"
#import "MirrorLanguage.h"
#import "MirrorTool.h"

@interface TimeTrackingLabel ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) MirrorDataModel *taskModel;

@property (nonatomic, strong) NSDate *nowTime;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, assign) NSTimeInterval timeInterval;

@end


@implementation TimeTrackingLabel

- (instancetype)initWithTask:(NSString *)taskName
{
    self = [super init];
    if (self) {
        self.taskModel = [MirrorStorage getTaskFromDB:taskName];
        self.text = [MirrorLanguage mirror_stringWithKey:@"counting"];
        self.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        self.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        self.textAlignment = NSTextAlignmentCenter;
        __weak typeof(self) weakSelf = self;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)1.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
            // 在iOS 10以后系统，苹果针对NSTimer进行了优化，使用Block回调方式，解决了循环引用问题。
            [weakSelf updateText];
        }];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)dealloc // 页面被销毁，销毁timer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview // 页面被游离，销毁timer
{
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview && self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)updateText
{
    BOOL printTimeStamp = NO; // 是否打印时间戳（平时不需要打印，出错debug的时候打印一下）
    NSLog(@"%@闪烁计时中: %@(now) - %@(start) = %f",[UIColor getEmoji:self.taskModel.color], [MirrorTool timeFromDate:self.nowTime printTimeStamp:printTimeStamp], [MirrorTool timeFromDate:self.startTime printTimeStamp:printTimeStamp], self.timeInterval);
    self.text = [[NSDateComponentsFormatter new] stringFromTimeInterval:self.timeInterval];
    
    if (round(self.timeInterval) >= 86400) { // 超过24小时立即停止计时
        [self.delegate destroyTimeTrackingLabel];
        [MirrorStorage stopTask:self.taskModel.taskName];
    }
    if (round(self.timeInterval) < 0) { // interval为负数立即停止计时
        [self.delegate destroyTimeTrackingLabel];
        [MirrorStorage stopTask:self.taskModel.taskName];
    }
}

- (NSDate *)nowTime
{
    return [NSDate now]; // 当前时间
}

- (NSDate *)startTime
{
    long startTimestamp = 0;
    NSArray *periods = self.taskModel.periods;
    if (periods.count > 0) {
        NSArray *lastPeriod = periods[periods.count-1];
        if (lastPeriod.count == 1) { // the last period is ongoing
            startTimestamp = [lastPeriod[0] longValue];
        }
    }
    // 使用 po round(([NSDate now]timeIntervalSince1970] - (86400-20))) 的结果替换下面的startTimestamp可以在20秒内看到20小时自动保存的效果
    NSDate *startTime = [NSDate dateWithTimeIntervalSince1970:startTimestamp];
    return startTime;
}

- (NSTimeInterval)timeInterval
{
    return [self.nowTime timeIntervalSinceDate:self.startTime];
}


@end
