//
//  SplitLineView.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SplitLineView : UIView

- (instancetype)initWithImage:(NSString *)imageName color:(UIColor *)color;

- (instancetype)initWithText:(NSString *)text color:(UIColor *)color;

- (void)updateText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
