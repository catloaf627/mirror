//
//  GridCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/2.
//

#import "GridCollectionViewCell.h"
#import "MirrorTool.h"
#import "UIColor+MirrorColor.h"

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
    CGFloat alpha = 1; //如果没有task的话，超级浅的灰色alpha为1
    NSInteger maxTime = 0; // 那一天哪个task时间最长
    NSInteger totalTime = 0; // 那一天的所有task的工作时间总和
    for (int i=0; i<component.thatDayTasks.count; i++) {
        NSInteger thisTaskTime = [MirrorTool getTotalTimeOfPeriods:component.thatDayTasks[i].periods];
        if (thisTaskTime > maxTime) {
            maxTime = thisTaskTime;
            winnerTaskColor = component.thatDayTasks[i].color;
        }
        totalTime = totalTime + thisTaskTime;
        if (totalTime>0*3600) alpha = 0.4;
        if (totalTime>3*3600) alpha = 0.7;
        if (totalTime>7*3600) alpha = 1.0;
    }
    // 某一天、最多任务的颜色、总体一天肝了多久(颜色越深，说明肝得越久，<3h alpha=0.4, 3-7h alpha=0.7, 7h+,alpha=1)
    self.backgroundColor = [[UIColor mirrorColorNamed:winnerTaskColor] colorWithAlphaComponent:alpha];
    if (isSelected) {
        self.layer.borderColor = [UIColor mirrorColorNamed:[UIColor mirror_getPulseColorType:winnerTaskColor]].CGColor;
        self.layer.borderWidth = 2;
    } else {
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 0;
    }
}


@end
