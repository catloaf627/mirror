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
#import "MirrorLanguage.h"

@interface EditTaskViewController ()

@property (nonatomic, strong) TimeTrackerTaskModel *taskModel;
@property (nonatomic, strong) UIColor *taskColor;
@property (nonatomic, strong) UITextField *editTaskNameTextField;
@property (nonatomic, strong) UILabel *editTaskNameHint;

@end

@implementation EditTaskViewController

- (instancetype)initWithTasks:(TimeTrackerTaskModel *)task
{
    self = [super init];
    if (self) {
        self.taskModel = task;
        self.taskColor = _taskModel.color;
        self.editTaskNameTextField.text = _taskModel.taskName;
    }
    return self;
}

- (void)viewDidLayoutSubviews
{
    // 编辑task页面为半屏
    [self.view setFrame:CGRectMake(0, kScreenHeight/5*1, kScreenWidth, kScreenHeight/5*4)];
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
        make.top.offset(20);
        make.centerX.offset(0);
        make.width.mas_equalTo(kScreenWidth - 40);
    }];
    [self.view addSubview:self.editTaskNameHint];
    [self.editTaskNameHint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.editTaskNameTextField.mas_bottom).offset(8);
        make.centerX.offset(0);
        make.width.mas_equalTo(kScreenWidth - 40);
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
        _editTaskNameTextField.textAlignment = NSTextAlignmentCenter;
    }
    return _editTaskNameTextField;
}

- (UILabel *)editTaskNameHint
{
    if (!_editTaskNameHint) {
        _editTaskNameHint = [UILabel new];
        _editTaskNameHint.text = [MirrorLanguage mirror_stringWithKey:@"edit_taskname_hint"];
        _editTaskNameHint.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
        _editTaskNameHint.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:12];
        _editTaskNameHint.textAlignment = NSTextAlignmentCenter;
        
    }
    return _editTaskNameHint;
}

@end
