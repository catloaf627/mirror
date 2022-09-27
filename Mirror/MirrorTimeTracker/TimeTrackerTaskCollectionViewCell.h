//
//  TimeTrackerTaskCollectionViewCell.h
//  Mirror
//
//  Created by wangyuqing on 2022/9/26.
//

#import <UIKit/UIKit.h>
#import "TimeTrackerTaskModel.h"

NS_ASSUME_NONNULL_BEGIN

static CGFloat const kInterspacing = 16;

@interface TimeTrackerTaskCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) TimeTrackerTaskModel *taskModel;

@end

NS_ASSUME_NONNULL_END
