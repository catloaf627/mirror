//
//  EditPeriodViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/17.
//

#import "EditPeriodViewController.h"
#import "MirrorMacro.h"
#import "MirrorDataModel.h"
#import "MirrorStorage.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>


static CGFloat const kEditPeriodVCPadding = 20;
static CGFloat const kHeightRatio = 0.8;

@interface EditPeriodViewController ()

@property (nonatomic, strong) NSString *taskName;
@property (nonatomic, assign) NSInteger periodIndex;

@property (nonatomic, strong) UILabel *hintLabel;

@end

@implementation EditPeriodViewController

- (instancetype)initWithTaskname:(NSString *)taskName periodIndex:(NSInteger)periodIndex
{
    self = [super init];
    if (self) {
        self.taskName = taskName;
        self.periodIndex = periodIndex;
        MirrorDataModel *task = [MirrorStorage getTaskFromDB:self.taskName];
        self.view.backgroundColor = [UIColor mirrorColorNamed:task.color];
        [self p_setupUI];
    }
    return self;
}

- (void)viewDidLayoutSubviews
{
    // 编辑task页面为半屏
    [self.view setFrame:CGRectMake(0, kScreenHeight*(1-kHeightRatio), kScreenWidth, kScreenHeight*kHeightRatio)];
    self.view.layer.cornerRadius = 20;
    self.view.layer.masksToBounds = YES;

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewGetsTapped:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self.view.superview addGestureRecognizer:tapRecognizer];
}

- (void)p_setupUI
{
    [self.view addSubview:self.hintLabel];
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kEditPeriodVCPadding);
        make.right.offset(-kEditPeriodVCPadding);
        make.top.offset(kEditPeriodVCPadding);
    }];
}

#pragma mark - Actions
// 给superview添加了点击手势（为了在点击上方不属于self.view的地方可以dismiss掉self）
- (void)viewGetsTapped:(UIGestureRecognizer *)tapRecognizer
{
    CGPoint touchPoint = [tapRecognizer locationInView:self.view];
    if (touchPoint.y <= 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Getters

- (UILabel *)hintLabel
{
    if (!_hintLabel) {
        _hintLabel = [UILabel new];
        _hintLabel.adjustsFontSizeToFitWidth = NO;
        _hintLabel.numberOfLines = 0;
        _hintLabel.textAlignment = NSTextAlignmentCenter;
        _hintLabel.text = @"你可以编辑任务的结束时间，但结束时间必须晚于开始时间。";
        _hintLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
    }
    return _hintLabel;
}



@end
