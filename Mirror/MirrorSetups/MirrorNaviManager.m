//
//  MirrorNaviManager.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/29.
//

#import "MirrorNaviManager.h"
#import <Masonry/Masonry.h>
#import "UIColor+MirrorColor.h"

static CGFloat const kCollectionViewPadding = 20; // 左右留白

@implementation MirrorNaviManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static MirrorNaviManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[MirrorNaviManager alloc]init];
    });
    return instance;
}

- (void)updateNaviItemWithTitle:(NSString *)title naviController:(UINavigationController *)naviController leftButton:(nullable UIButton *)leftButton rightButton:(nullable UIButton *)rightButton
{
    
    for (UIView *view in naviController.navigationBar.subviews) {
        if ([view isKindOfClass:UIButton.class]) {
            [view removeFromSuperview];
        }
    }
    if ([title isEqualToString:@""]) return; // 二级页，删完button就返回
    
    // 设置title是为了从start/today/data三个主vc点进其他vc的时候，back button位置有个标注。
    naviController.navigationBar.topItem.title = title;
    // 设置为透明色是为了start/today/data三个主vc好看
    naviController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor clearColor], NSForegroundColorAttributeName, nil];
    
    if (leftButton) {
        leftButton.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [naviController.navigationBar addSubview:leftButton];
        [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(kCollectionViewPadding);
            make.centerY.offset(0);
            make.width.height.mas_equalTo(naviController.navigationBar.frame.size.height);
        }];
    }
    if (rightButton) {
        rightButton.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [naviController.navigationBar addSubview:rightButton];
        [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.offset(-kCollectionViewPadding);
            make.centerY.offset(0);
            make.width.height.mas_equalTo(naviController.navigationBar.frame.size.height);
        }];
    }
}

@end
