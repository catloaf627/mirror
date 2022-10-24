//
//  ThemeCollectionViewCell.h
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/28.
//

#import <UIKit/UIKit.h>
#import "ToggleCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThemeCollectionViewCell : ToggleCollectionViewCell

+ (NSString *)identifier;
- (void)configCell;

@end

NS_ASSUME_NONNULL_END
