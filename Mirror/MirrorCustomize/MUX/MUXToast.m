//
//  MUXToast.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/7.
//

#import "MUXToast.h"

@implementation MUXToast

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
        const CGFloat *components = CGColorGetComponents([UIColor mirrorColorNamed:color].CGColor);
        subSubView.backgroundColor = [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:0.5f];
    }
    NSMutableAttributedString *AS = [[NSMutableAttributedString alloc] initWithString:message];
    [AS addAttribute: NSForegroundColorAttributeName value: [UIColor whiteColor] range: NSMakeRange(0,AS.length)];
    [alert setValue:AS forKey:@"attributedTitle"];
    [vc presentViewController:alert animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:^{
        }];
    });
}

@end
