//
//  EditTaskViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/29.
//

#import "EditTaskViewController.h"
#import "MirrorMacro.h"
#import <Masonry/Masonry.h>
#import "UIColor+MirrorColor.h"

@interface EditTaskViewController ()

@property (nonatomic, strong) UIColor *taskColor;
@property (nonatomic, strong) UITextField *editTaskNameTextField;
@property (nonatomic, strong) TimeTrackerTaskModel *taskModel;
@property (nonatomic, assign) NSInteger taskIndex;

@end

@implementation EditTaskViewController

- (instancetype)initWithTasks:(NSMutableArray<TimeTrackerTaskModel *> *)tasks index:(NSInteger)index
{
    self = [super init];
    if (self) {
        self.taskIndex = index;
        self.taskModel = tasks[index];
        self.taskColor = _taskModel.color;
        self.editTaskNameTextField.text = _taskModel.taskName;
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

- (void)viewDidDisappear:(BOOL)animated
{
    self.taskModel.taskName = self.editTaskNameTextField.text; // 保存taskname
    [self.delegate updateTasks];
}

- (void)p_setupUI
{
    self.view.backgroundColor = _taskColor;
    [self.view addSubview:self.editTaskNameTextField];
    [self.editTaskNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(14);
        make.centerX.offset(0);
    }];
}

#pragma mark - Getters

- (UITextField *)editTaskNameTextField
{
    if (!_editTaskNameTextField) {
        _editTaskNameTextField = [UITextField new];
        _editTaskNameTextField.text = self.taskModel.taskName;
        _editTaskNameTextField.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        _editTaskNameTextField.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:20];
        _editTaskNameTextField.enabled = YES;
    }
    return _editTaskNameTextField;
}

@end
