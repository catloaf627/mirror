//
//  LeftAnimation.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LeftAnimation : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isPresent; // is present or is dismiss

@end

NS_ASSUME_NONNULL_END
