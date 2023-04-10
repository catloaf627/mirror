//
//  TimeTrackerViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/25.
//

#import "TimeTrackerViewController.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>
#import "TimeTrackerTaskCollectionViewCell.h"
#import "TimeTrackerAddTaskCollectionViewCell.h"
#import "MirrorDataManager.h"
#import "MirrorMacro.h"
#import "MirrorTabsManager.h"
#import "EditTaskViewController.h"
#import "AddTaskViewController.h"
#import "TimeTrackingView.h"
#import "TimeTrackingLabel.h"
#import "MirrorStorage.h"
#import "MirrorTool.h"
#import "MUXToast.h"
#import "MirrorSettings.h"

static CGFloat const kCellSpacing = 16; // cell之间的上下间距
static CGFloat const kCollectionViewPadding = 20; // 左右留白

@interface TimeTrackerViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DismissEditSheetProtocol, TimeTrackingViewProtocol>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation TimeTrackerViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 设置通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartVC) name:MirrorSwitchThemeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartVC) name:MirrorSwitchLanguageNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartVC) name:MirrorSwitchImmersiveModeNotification object:nil]; // 比其他vc多监听一个通知
        // 数据通知 (直接数据驱动UI，本地数据变动必然导致这里的UI变动)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopNotification:) name:MirrorTaskStopNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskEditNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskDeleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskArchiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskCreateNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)restartVC
{
    // 将vc.view里的所有subviews全部置为nil
    self.collectionView = nil;
    // 将vc.view里的所有subviews从父view上移除
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 更新tab item
    [[MirrorTabsManager sharedInstance] updateTimeTabItemWithTabController:self.tabBarController];
    [self viewDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self  p_setupUI];
}

- (void)p_setupUI
{
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view).offset(kCollectionViewPadding);
            make.right.mas_equalTo(self.view).offset(-kCollectionViewPadding);
            make.top.mas_equalTo(self.view).offset(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);
            make.bottom.mas_equalTo(self.view).offset(-kTabBarHeight);
    }];
    if ([MirrorSettings appliedImmersiveMode]) {
        MirrorDataModel *ongoingTask = [MirrorStorage getOngoingTaskFromDB];
        if (ongoingTask) {
            [self openTimeTrackingViewWithTask:ongoingTask];
        }
    }
}

#pragma mark - Actions

// 长按唤起task编辑页面
- (void)cellGetsLongPressed:(UISwipeGestureRecognizer *)swipeRecognizer
{
    CGPoint touchPoint = [swipeRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
    if (indexPath == nil) {
        return;
    }
    MirrorDataModel *task = [MirrorDataManager activatedTasksWithAddTask][indexPath.item];
    if (task.isAddTaskModel) {
        // 长按[+]均可以像点击一样唤起add task
        AddTaskViewController *addVC = [AddTaskViewController new];
        [self.navigationController presentViewController:addVC animated:YES completion:nil];
    }
    EditTaskViewController *editVC = [[EditTaskViewController alloc]initWithTasks:[MirrorDataManager activatedTasksWithAddTask][indexPath.item]];
    editVC.delegate = self;
    [self.navigationController presentViewController:editVC animated:YES completion:nil];
}

#pragma mark - TimeTrackingViewProtocol

- (void)destroyTimeTrackingView
{
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:TimeTrackingView.class]) {
            [view removeFromSuperview];
        }
    }
}

- (void)openTimeTrackingViewWithTask:(MirrorDataModel *)task
{
    TimeTrackingView *timeTrackingView = [[TimeTrackingView alloc]initWithTaskName:task.taskName];
    timeTrackingView.delegate = self;
    [self.view addSubview:timeTrackingView];
    [timeTrackingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.offset(0);
    }];
}

# pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)selectedIndexPath
{
    MirrorDataModel *selectedModel = [MirrorDataManager activatedTasksWithAddTask][selectedIndexPath.item];
    // 点击了[+]
    if (selectedModel.isAddTaskModel) {
        AddTaskViewController *addVC = [AddTaskViewController new];
        [self.navigationController presentViewController:addVC animated:YES completion:nil];
        return;
    }
    // 点击了task model
    if (selectedModel.isOngoing) { // 点击了正在计时的selectedCell，停止selectedCell的计时
        [MirrorStorage stopTask:selectedModel.taskName];
    } else { // 点击了未开始计时的selectedCell，停止所有其他计时cell，再开始selectedCell的计时
        [MirrorStorage stopAllTasksExcept:selectedModel.taskName];
        [MirrorStorage startTask:selectedModel.taskName];
        if ([MirrorSettings appliedImmersiveMode]) {
            [self openTimeTrackingViewWithTask:selectedModel];
        }
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MirrorDataModel *taskModel = [MirrorDataManager activatedTasksWithAddTask][indexPath.item];
    if (taskModel.isAddTaskModel) {
        TimeTrackerAddTaskCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[TimeTrackerAddTaskCollectionViewCell identifier] forIndexPath:indexPath];
        [cell setupAddTaskCell];
        return cell;
    } else {
        TimeTrackerTaskCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[TimeTrackerTaskCollectionViewCell identifier] forIndexPath:indexPath];
        [cell configWithModel:taskModel];
        return cell;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [MirrorDataManager activatedTasksWithAddTask].count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((kScreenWidth - kCollectionViewPadding - kCollectionViewPadding -kCellSpacing)/2, 90);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kCellSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kCellSpacing;
}

#pragma mark - Notifications (都需要reload data)

- (void)reloadData
{
    // 如果有闪烁计时，销毁！
    for (UIView *viewi in self.collectionView.subviews) {
        if ([viewi isKindOfClass:TimeTrackerTaskCollectionViewCell.class]) {
            TimeTrackerTaskCollectionViewCell *cell =  (TimeTrackerTaskCollectionViewCell *)viewi;
            for (UIView *viewj in cell.contentView.subviews) {
                if ([viewj isKindOfClass:TimeTrackingLabel.class]) {
                    [viewj removeFromSuperview];
                }
            }
        }
    }
    // 如果有全屏计时，销毁！
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:TimeTrackingView.class]) {
            [view removeFromSuperview];
        }
    }
    [self.collectionView reloadData];
}

- (void)stopNotification:(NSNotification *)noti
{
    NSString *taskName = noti.userInfo[@"taskName"];
    TaskSavedType savedType = [noti.userInfo[@"TaskSavedType"] integerValue];
    [MUXToast taskSaved:taskName onVC:self type:savedType];
    [self reloadData];
}

#pragma mark - Getters

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = self.view.backgroundColor;
        
        [_collectionView registerClass:[TimeTrackerTaskCollectionViewCell class] forCellWithReuseIdentifier:[TimeTrackerTaskCollectionViewCell identifier]];
        [_collectionView registerClass:[TimeTrackerAddTaskCollectionViewCell class] forCellWithReuseIdentifier:[TimeTrackerAddTaskCollectionViewCell identifier]];
        
        // 长按手势
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(cellGetsLongPressed:)];
        longPressRecognizer.minimumPressDuration = 0.5;
        [_collectionView addGestureRecognizer:longPressRecognizer];
        
    }
    return _collectionView;
}

@end
