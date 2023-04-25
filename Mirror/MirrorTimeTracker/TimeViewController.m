//
//  TimeTrackerViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/25.
//

#import "TimeViewController.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>
#import "TimeTrackerTaskCollectionViewCell.h"
#import "TimeTrackerAddTaskCollectionViewCell.h"
#import "MirrorDataManager.h"
#import "MirrorMacro.h"
#import "MirrorTabsManager.h"
#import "EditTaskViewController.h"
#import "AddTaskViewController.h"
#import "TimeTrackingViewController.h"
#import "TimeEditingViewController.h"
#import "MirrorStorage.h"
#import "MirrorTool.h"
#import "MirrorSettings.h"
#import "SettingsViewController.h"
#import "LeftAnimation.h"
#import "CellAnimation.h"

static CGFloat const kCellSpacing = 16; // cell之间的上下间距
static CGFloat const kCollectionViewPadding = 20; // 左右留白

@interface TimeViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;
@property (nonatomic, strong) UIButton *allTasksButton;
@property (nonatomic, assign) CGPoint collectionViewPoint; // self.collectionView.x, self.collectionView.y
@property (nonatomic, assign) CGRect selectedCellFrame; // cell.x, cell.y, cell.width, cell.height

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation TimeViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 设置通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartVC) name:MirrorSwitchThemeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartVC) name:MirrorSwitchLanguageNotification object:nil];
        // 数据通知 (直接数据驱动UI，本地数据变动必然导致这里的UI变动)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskStopNotification object:nil];
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
    self.settingsButton = nil;
    self.allTasksButton = nil;
    // 将vc.view里的所有subviews从父view上移除
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 更新tabbar
    [[MirrorTabsManager sharedInstance] updateTimeTabItemWithTabController:self.tabBarController];
    [self viewDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self  p_setupUI];
}

/*
 神奇：必须在viewDidAppear里重新update下self.collectionView的top-constraint
 viewDidLoad时，navigationBar的y和height都是0 (这个时候self.navigationController都还是nil)
 viewWillAppear时，navigationBar的y是0，但height是44
 viewDidAppear时，navigationBar的y是50，但height是44 (这个时候的navigationBar的frame才真正稳定下来)
 */
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);
    }];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.collectionViewPoint = self.collectionView.frame.origin; // update collectionview frame的时机
}

- (void)p_setupUI
{
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kCollectionViewPadding);
        make.right.mas_equalTo(self.view).offset(-kCollectionViewPadding);
        make.top.mas_equalTo(self.view).offset(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height); // 这行没用，最后还是要在viewDidAppear里重新udpate才行
        make.bottom.mas_equalTo(self.view).offset(-kTabBarHeight);
    }];
    // Settings button
    [self.view addSubview:self.settingsButton];
    [self.settingsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kCollectionViewPadding);
        make.bottom.mas_equalTo(self.collectionView.mas_top);
        make.width.height.mas_equalTo(40);
    }];
    [self.view addSubview:self.allTasksButton];
    [self.allTasksButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-kCollectionViewPadding);
        make.bottom.mas_equalTo(self.collectionView.mas_top);
        make.width.height.mas_equalTo(40);
    }];
    UIScreenEdgePanGestureRecognizer *edgeRecognizer = [UIScreenEdgePanGestureRecognizer new];
    edgeRecognizer.edges = UIRectEdgeLeft;
    [edgeRecognizer addTarget:self action:@selector(edgeGestureRecognizerAction:)];
    [self.view addGestureRecognizer:edgeRecognizer];
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
    [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight] impactOccurred];
    MirrorDataModel *task = [MirrorDataManager activatedTasksWithAddTask][indexPath.item];
    if (task.isAddTaskModel) { // 长按[+]均可以像点击一样唤起add task
        AddTaskViewController *addVC = [AddTaskViewController new];
        [self.navigationController presentViewController:addVC animated:YES completion:nil];
    } else { // 长按task
        EditTaskViewController *editVC = [[EditTaskViewController alloc]initWithTaskname:[MirrorDataManager activatedTasksWithAddTask][indexPath.item].taskName];
                [self.navigationController presentViewController:editVC animated:YES completion:nil];
    }
}

- (void)goToSettings
{
    [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight] impactOccurred];
    SettingsViewController * settingsVC = [[SettingsViewController alloc] init];
    settingsVC.transitioningDelegate = self;
    settingsVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:settingsVC animated:YES completion:nil];
}

- (void)goToAllTasks
{
    
}


#pragma mark - Collection view delegate

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
    if (selectedModel.isOngoing) { // 点击了正在计时的selectedCell，如果有这种情况就是出bug了！
        [MirrorStorage stopTask:selectedModel.taskName at:[NSDate now] periodIndex:0];
    } else { // 点击了未开始计时的selectedCell，打开选择页面：直接编辑or开始计时
        self.selectedCellFrame = [self.collectionView cellForItemAtIndexPath:selectedIndexPath].frame; // update selected cell frame的时机
        TimeEditingViewController *timeEditingVC = [[TimeEditingViewController alloc] initWithTaskName:selectedModel.taskName];
        timeEditingVC.transitioningDelegate = self; // 动画
        timeEditingVC.modalPresentationStyle = UIModalPresentationCustom;
        timeEditingVC.cellFrame = CGRectMake(self.collectionViewPoint.x + self.selectedCellFrame.origin.x, self.collectionViewPoint.y + self.selectedCellFrame.origin.y, self.selectedCellFrame.size.width, self.selectedCellFrame.size.height);
        [self presentViewController:timeEditingVC animated:YES completion:nil];
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MirrorDataModel *taskModel = [MirrorDataManager activatedTasksWithAddTask][indexPath.item];
    if (taskModel.isOngoing) {
        TimeTrackingViewController * timeTrackingVC = [[TimeTrackingViewController alloc] initWithTaskName:taskModel.taskName];
        timeTrackingVC.transitioningDelegate = self;
        timeTrackingVC.modalPresentationStyle = UIModalPresentationCustom;
        timeTrackingVC.cellFrame = CGRectMake(self.collectionViewPoint.x + self.selectedCellFrame.origin.x, self.collectionViewPoint.y + self.selectedCellFrame.origin.y, self.selectedCellFrame.size.width, self.selectedCellFrame.size.height);
        [self presentViewController:timeTrackingVC animated:NO completion:nil]; // present time tracking vc 一定是通过 time editing vc 结束来的，所以不需要动画。
    }
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
    [self.collectionView reloadData];
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
        longPressRecognizer.minimumPressDuration = 0.25;
        [_collectionView addGestureRecognizer:longPressRecognizer];
        
    }
    return _collectionView;
}

- (UIButton *)settingsButton
{
    if (!_settingsButton) {
        _settingsButton = [UIButton new];
        UIImage *iconImage = [[UIImage systemImageNamed:@"ellipsis"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [_settingsButton setImage:[iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _settingsButton.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [_settingsButton addTarget:self action:@selector(goToSettings) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingsButton;
}

- (UIButton *)allTasksButton
{
    if (!_allTasksButton) {
        _allTasksButton = [UIButton new];
        UIImage *iconImage = [[UIImage systemImageNamed:@"tray"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [_allTasksButton setImage:[iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _allTasksButton.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        [_allTasksButton addTarget:self action:@selector(goToAllTasks) forControlEvents:UIControlEventTouchUpInside];
    }
    return _allTasksButton;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    if ([presented isKindOfClass:SettingsViewController.class]) { // Settings
        LeftAnimation *animation = [LeftAnimation new];
        animation.isPresent = YES;
        return animation;
    } else { // Time editing / Time tracking
        CellAnimation *animation = [CellAnimation new];
        animation.isPresent = YES;
        animation.cellFrame = CGRectMake(self.collectionViewPoint.x + self.selectedCellFrame.origin.x, self.collectionViewPoint.y + self.selectedCellFrame.origin.y, self.selectedCellFrame.size.width, self.selectedCellFrame.size.height);
        return animation;
    }
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return self.interactiveTransition;
}

// 从左边缘滑动唤起settings
- (void)edgeGestureRecognizerAction:(UIScreenEdgePanGestureRecognizer *)pan
{
    //产生百分比
    CGFloat process = [pan translationInView:self.view].x / (self.view.frame.size.width);
    
    process = MIN(1.0,(MAX(0.0, process)));
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.interactiveTransition = [UIPercentDrivenInteractiveTransition new];
        // 触发present转场动画
        [self goToSettings];
    }else if (pan.state == UIGestureRecognizerStateChanged){
        [self.interactiveTransition updateInteractiveTransition:process];
    }else if (pan.state == UIGestureRecognizerStateEnded
              || pan.state == UIGestureRecognizerStateCancelled){
        if (process > 0.3) {
            [ self.interactiveTransition finishInteractiveTransition];
        }else{
            [ self.interactiveTransition cancelInteractiveTransition];
        }
        self.interactiveTransition = nil;
    }
}


@end
