//
//  EditTaskViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/29.
//

#import "EditTaskViewController.h"
#import "MirrorMacro.h"

@interface EditTaskViewController ()

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) TimeTrackerTaskModel *model;

@end

@implementation EditTaskViewController

- (instancetype)initWithTasks:(NSMutableArray<TimeTrackerTaskModel *> *)tasks index:(NSInteger)index
{
    self = [super init];
    if (self) {
        _model = tasks[index];
        _color = _model.color;
        _label.text = _model.taskName;
    }
    return self;
}

- (void)viewDidLayoutSubviews
{
    // 编辑task页面为半屏
    [self.view setFrame:CGRectMake(0, kScreenHeight/5 *2, kScreenWidth, kScreenHeight/5*3)];
    self.view.layer.cornerRadius = 20;
    self.view.layer.masksToBounds = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_setupUI];
}

- (void)p_setupUI
{
    self.view.backgroundColor = _color;
}

@end
