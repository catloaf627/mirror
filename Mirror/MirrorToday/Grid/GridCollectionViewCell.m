//
//  GridCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/2.
//

#import "GridCollectionViewCell.h"
#import "MirrorTool.h"
#import "UIColor+MirrorColor.h"
#import "MirrorSettings.h"

@implementation GridCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configWithGridComponent:(GridComponent *)component isSelected:(BOOL)isSelected
{
    if (!component.isValid) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 0;
        return;
    }
    
    self.layer.cornerRadius = 2;
    NSInteger winnerTaskColor = MirrorColorTypeAddTaskCellBG; //如果没有task的话，用这个超级浅的灰色兜底
    CGFloat alpha = 0;
    BOOL isEmpty = YES;
    NSInteger maxTime = 0; // 那一天哪个task时间最长
    NSInteger totalTime = 0; // 那一天的所有task的工作时间总和
    for (int i=0; i<component.thatDayTasks.count; i++) {
        isEmpty = NO;
        NSInteger thisTaskTime = [MirrorTool getTotalTimeOfPeriods:component.thatDayTasks[i].periods];
        if (thisTaskTime > maxTime) {
            maxTime = thisTaskTime;
            winnerTaskColor = component.thatDayTasks[i].color;
        }
        totalTime = totalTime + thisTaskTime;
        if (totalTime>0*3600) alpha = 0.5;
        if (totalTime>3*3600) alpha = 0.8;
        if (totalTime>7*3600) alpha = 1.0;
    }
    if (isEmpty) { // 无数据
        self.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeAddTaskCellBG];
    } else if (![MirrorSettings appliedShowShade] && alpha != 0) {  // 彩色模式 & 有数据
        self.backgroundColor = [UIColor mirrorColorNamed:winnerTaskColor];
    } else if ([MirrorSettings appliedShowShade] && alpha != 0) {  // 深浅模式 & 有数据
        self.backgroundColor = [[UIColor mirrorColorNamed:[MirrorSettings preferredShadeColor]] colorWithAlphaComponent:alpha];
    }
    if (isSelected) {
        self.layer.borderColor = [UIColor mirrorColorNamed:MirrorColorTypeText].CGColor;
        self.layer.borderWidth = 2;
    } else {
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 0;
    }
}


@end
