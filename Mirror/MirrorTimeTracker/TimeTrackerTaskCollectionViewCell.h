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

@protocol EditTaskProtocol <NSObject>

- (void)goToEdit:(NSString *)taskname;

@end

@interface TimeTrackerTaskCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) UIViewController<EditTaskProtocol> *delegate;

+ (NSString *)identifier;
- (void)configWithModel:(MirrorDataModel *)taskModel;

@end

NS_ASSUME_NONNULL_END
