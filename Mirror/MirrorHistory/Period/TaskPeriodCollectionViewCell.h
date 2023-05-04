//
//  TaskPeriodCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/15.
//

#import <UIKit/UIKit.h>
#import "MirrorTaskModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VCForPeriodCellProtocol <NSObject>

@end

@interface TaskPeriodCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) UIViewController<VCForPeriodCellProtocol> *delegate;

+ (NSString *)identifier;
- (void)configWithTaskname:(NSString *)taskName periodIndex:(NSInteger)index;
- (void)showOrHideOriginalIndex;


@end

NS_ASSUME_NONNULL_END
