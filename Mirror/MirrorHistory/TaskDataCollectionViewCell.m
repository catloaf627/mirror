//
//  TaskDataCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/10/27.
//

#import "TaskDataCollectionViewCell.h"
#import "UIColor+MirrorColor.h"

@implementation TaskDataCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configCellWithModel:(TimeTrackerTaskModel *)model
{
    self.backgroundColor = [UIColor mirrorColorNamed:model.color];
}

@end
