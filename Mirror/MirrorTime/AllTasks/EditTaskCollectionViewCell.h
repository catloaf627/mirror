//
//  EditTaskCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VCForTaskCellProtocol <NSObject>

@end

@interface EditTaskCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) UIViewController<VCForTaskCellProtocol> *delegate;

+ (NSString *)identifier;
- (void)configWithIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
