//
//  EditTaskViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/29.
//

#import "EditTaskViewController.h"

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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_setupUI];
}

- (void)p_setupUI
{
    self.view.backgroundColor = _color;
}

@end
