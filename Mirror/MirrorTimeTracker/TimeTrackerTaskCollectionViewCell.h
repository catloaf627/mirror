//
//  TimeTrackerTaskCollectionViewCell.h
//  Mirror
//
//  Created by wangyuqing on 2022/9/26.
//

#import <UIKit/UIKit.h>
#import "MirrorDataModel.h"

NS_ASSUME_NONNULL_BEGIN

static CGFloat const kInterspacing = 16;

@interface TimeTrackerTaskCollectionViewCell : UICollectionViewCell

+ (NSString *)identifier;
- (void)configWithTaskname:(NSString *)taskName;

@end

NS_ASSUME_NONNULL_END
