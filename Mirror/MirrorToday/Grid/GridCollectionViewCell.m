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

- (void)configWithData:(NSMutableArray<MirrorDataModel *> *)data isSelected:(BOOL)isSelected
{
    long maxTime = 0;
    long totalTime = 0;
    CGFloat alpha = 0;
    MirrorColorType winnerColor = MirrorColorTypeAddTaskCellBG;
    for (int i=0; i<data.count; i++) {
        long taskTime = [MirrorTool getTotalTimeOfPeriods:data[i].records];
        if (taskTime > maxTime) {
            maxTime = taskTime;
            winnerColor = data[i].taskModel.color;
        }
        totalTime = totalTime + taskTime;
    }
    if (totalTime>0*3600) alpha = 0.5;
    if (totalTime>3*3600) alpha = 0.8;
    if (totalTime>7*3600) alpha = 1.0;
    
    if (totalTime == 0) { // 无数据
        self.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeAddTaskCellBG];
    } else if (![MirrorSettings appliedShowShade] && alpha != 0) {  // 彩色模式 & 有数据
        self.backgroundColor = [UIColor mirrorColorNamed:winnerColor];
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
