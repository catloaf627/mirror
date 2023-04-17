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

static CGFloat const kEditPeriodVCPadding = 20;
static CGFloat const kHeightRatio = 0.8;

@interface EditPeriodViewController ()

@property (nonatomic, strong) NSString *taskName;
@property (nonatomic, assign) NSInteger periodIndex;

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
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewDidLayoutSubviews
{
    // 编辑task页面为半屏
    [self.view setFrame:CGRectMake(0, kScreenHeight*(1-kHeightRatio), kScreenWidth, kScreenHeight*kHeightRatio)];
    self.view.layer.cornerRadius = 20;
    self.view.layer.masksToBounds = YES;

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewGetsTapped:)];
    tapRecognizer.numberOfTapsRequired = 1;
//    tapRecognizer.delegate = self;
    [self.view.superview addGestureRecognizer:tapRecognizer];
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



@end
