//
//  MirrorNaviManager.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/29.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MirrorNaviManager : NSObject

+ (instancetype)sharedInstance;

- (void)updateNaviItemWithNaviController:(UINavigationController *)naviController title:(NSString *)title leftButton:(nullable UIButton *)leftButton rightButton:(nullable UIButton *)rightButton;


@end

NS_ASSUME_NONNULL_END
