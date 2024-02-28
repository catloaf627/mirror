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
    CGFloat alpha = 0;
    _totalTime = 0;
    MirrorColorType winnerColor = MirrorColorTypeAddTaskCellBG;
    for (int i=0; i<data.count; i++) {
        long taskTime = [MirrorTool getTotalTimeOfPeriods:data[i].records];
        if (taskTime > maxTime) {
            maxTime = taskTime;
            winnerColor = data[i].taskModel.color;
        }
        _totalTime = _totalTime + taskTime;
    }
    if (_totalTime>0*3600) alpha = 0.2; // 最浅为0.2，再浅就看不清了
    if (_totalTime>1*3600) alpha = 0.3;
    if (_totalTime>2*3600) alpha = 0.4;
    if (_totalTime>3*3600) alpha = 0.5;
    if (_totalTime>4*3600) alpha = 0.6;
    if (_totalTime>5*3600) alpha = 0.7;
    if (_totalTime>6*3600) alpha = 0.8;
    if (_totalTime>7*3600) alpha = 0.9;
    if (_totalTime>8*3600) alpha = 1.0; // 8小时以上即为最深色块
    
    if (_totalTime == 0) { // 无数据
        self.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeAddTaskCellBG];
    } else if (![MirrorSettings appliedHeatmap] && alpha != 0) {  // 彩色模式 & 有数据
        self.backgroundColor = [UIColor mirrorColorNamed:winnerColor];
    } else if ([MirrorSettings appliedHeatmap] && alpha != 0) {  // 深浅模式 & 有数据
        self.backgroundColor = [[UIColor mirrorColorNamed:[MirrorSettings preferredHeatmapColor]] colorWithAlphaComponent:alpha];
    }
    if (isSelected) {
        self.layer.borderColor = [UIColor mirrorColorNamed:MirrorColorTypeText].CGColor;
        self.layer.borderWidth = 2;
        self.layer.cornerRadius = 2;
    } else {
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 0;
        self.layer.cornerRadius = 0;
    }
}


@end
