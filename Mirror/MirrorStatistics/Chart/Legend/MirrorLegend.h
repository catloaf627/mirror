//
//  MirrorLegend.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MirrorLegendDelegate <NSObject> // push viewcontroller用

@end

@interface MirrorLegend : UIView

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) UIViewController<MirrorLegendDelegate> *delegate;
- (CGFloat)legendViewHeight;
@end

NS_ASSUME_NONNULL_END
