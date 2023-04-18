//
//  ToggleCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/10/24.
//

#import <UIKit/UIKit.h>
#import "UIColor+MirrorColor.h"

NS_ASSUME_NONNULL_BEGIN

@interface ToggleCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UISwitch *toggle;

- (void)configCellWithTitle:(NSString *)title color:(MirrorColorType)color;

@end

NS_ASSUME_NONNULL_END
