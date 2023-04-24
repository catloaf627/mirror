//
//  TimeEditingViewController.h
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PresentCountingPageProtocol <NSObject> // 只是为了present出计时页面

- (void)presentCountingPageWithTaskName:(NSString *)taskName;

@end

@interface TimeEditingViewController : UIViewController

@property (nonatomic, weak) UIViewController<PresentCountingPageProtocol> *presentCountingPageDelegate;
@property (nonatomic, assign) CGRect cellFrame;
- (instancetype)initWithTaskName:(NSString *)taskName;

@end

NS_ASSUME_NONNULL_END
