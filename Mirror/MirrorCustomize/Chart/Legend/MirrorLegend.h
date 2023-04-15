//
//  MirrorLegend.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MirrorLegend : UIView

@property (nonatomic, strong) UICollectionView *collectionView;
- (CGFloat)legendViewHeight;
@end

NS_ASSUME_NONNULL_END
