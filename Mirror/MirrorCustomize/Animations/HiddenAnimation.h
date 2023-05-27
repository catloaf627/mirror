//
//  HiddenAnimation.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/27.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HiddenAnimation : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isPresent; // is present or is dismiss
@property (nonatomic, assign) CGRect buttonFrame;

@end

NS_ASSUME_NONNULL_END
