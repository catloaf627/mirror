//
//  ColorCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/30.
//

#import <UIKit/UIKit.h>
#import "UIColor+MirrorColor.h"

NS_ASSUME_NONNULL_BEGIN

@interface MirrorColorModel : NSObject // 数据源的类十分简单，直接写在cell里
@property (nonatomic, assign) MirrorColorType color;
@property (nonatomic, assign) BOOL isSelected;
@end

@interface ColorCollectionViewCell : UICollectionViewCell

- (void)configWithModel:(MirrorColorModel *)model;
+ (NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
