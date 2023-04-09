//
//  MUXToast.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/7.
//

#import "MUXToast.h"
#import "MirrorLanguage.h"
#import "MirrorDataModel.h"
#import "MirrorStorage.h"

@implementation MUXToast

#pragma mark - Public

+ (void)taskSaved:(NSString *)taskName onVC:(UIViewController *)vc
{
    MirrorDataModel *task = [MirrorStorage getTaskFromDB:taskName];
    if (task.periods.count <= 0 || task.periods[task.periods.count -1].count != 2) return;
    double latestPeriodInterval = [task.periods[task.periods.count -1][1] doubleValue] - [task.periods[task.periods.count -1][0] doubleValue];
    NSString *hintInfo = [MirrorLanguage mirror_stringWithKey:@"task_has_been_done" with1Placeholder:taskName with2Placeholder:[[NSDateComponentsFormatter new] stringFromTimeInterval:latestPeriodInterval]];
    if (round(latestPeriodInterval) >= 86400) { // 超过24小时立即停止计时
        hintInfo = [MirrorLanguage mirror_stringWithKey:@"reached_limited_time" with1Placeholder:taskName];
    }
    [MUXToast show:hintInfo onVC:vc color:task.color];
}

#pragma mark - Private

+ (void)show:(NSString *)message onVC:(UIViewController *)vc color:(MirrorColorType)color
{
    if ([message isEqualToString:@""]) {
        return;
    }
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:nil
                                                                  message:@""
                                                           preferredStyle:UIAlertControllerStyleAlert];
    UIView *firstSubview = alert.view.subviews.firstObject;
    UIView *alertContentView = firstSubview.subviews.firstObject;
    for (UIView *subSubView in alertContentView.subviews) {
        if (color) {
            const CGFloat *components = CGColorGetComponents([UIColor mirrorColorNamed:color].CGColor);
            subSubView.backgroundColor = [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:0.5f];
        } else {
            subSubView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
        }
    }
    NSMutableAttributedString *AS = [[NSMutableAttributedString alloc] initWithString:message];
    [AS addAttribute: NSForegroundColorAttributeName value: [UIColor mirrorColorNamed:MirrorColorTypeText] range: NSMakeRange(0,AS.length)];
    [alert setValue:AS forKey:@"attributedTitle"];
    [vc presentViewController:alert animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:^{
        }];
    });
}


@end
