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
#import "MirrorMacro.h"
#import "MirrorTabsManager.h"
#import "MirrorNaviManager.h"
#import "AddTaskViewController.h"
#import "TimeTrackingViewController.h"
#import "TimeEditingViewController.h"
#import "MirrorStorage.h"
#import "MirrorTool.h"
#import "MirrorSettings.h"
#import "SettingsViewController.h"
#import "LeftAnimation.h"
#import "CellAnimation.h"
#import "EditTasksViewController.h"
#import "MirrorLanguage.h"

static CGFloat const kCellSpacing = 16; // cell之间的上下间距
static CGFloat const kCollectionViewPadding = 20; // 左右留白

@interface TimeViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;
@property (nonatomic, strong) UIButton *editTasksButton;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskCreateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskChangeOrderNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskArchiveNotification object:nil];// 比其他vc多监听一个archive通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorPeriodDeleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorPeriodEditNotification object:nil];
        
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
    // 更新tabbar 和 navibar
    [[MirrorTabsManager sharedInstance] updateTimeTabItemWithTabController:self.tabBarController];
    if (self.tabBarController.selectedIndex == 0) {
        [[MirrorNaviManager sharedInstance] updateNaviItemWithNaviController:self.navigationController title:@"" leftButton:self.settingsButton rightButton:self.editTasksButton];
    }
    [self p_setupUI];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self  p_setupUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[MirrorNaviManager sharedInstance] updateNaviItemWithNaviController:self.navigationController title:@"" leftButton:self.settingsButton rightButton:self.editTasksButton];
    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);
    }];
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

- (void)p_setupUI
{
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kCollectionViewPadding);
        make.right.mas_equalTo(self.view).offset(-kCollectionViewPadding);
        make.top.mas_equalTo(self.view).offset(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height); // viewdidload时机过早，navi信息还没ready，需要在viewdidappear里再reset下
        make.bottom.mas_equalTo(self.view).offset(-kTabBarHeight);
    }];
    UIScreenEdgePanGestureRecognizer *edgeRecognizer = [UIScreenEdgePanGestureRecognizer new];
    edgeRecognizer.edges = UIRectEdgeLeft;
    [edgeRecognizer addTarget:self action:@selector(edgeGestureRecognizerAction:)];
    [self.view addGestureRecognizer:edgeRecognizer];
}

#pragma mark - Actions

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
    [self.navigationController pushViewController:[EditTasksViewController new] animated:YES];
}


#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)selectedIndexPath
{
    MirrorTaskModel *selectedModel = [MirrorStorage tasksWithoutArchiveWithAddNew][selectedIndexPath.item];
    // 点击了[+]
    if (selectedModel.isAddTaskModel) {
        AddTaskViewController *addVC = [AddTaskViewController new];
        [self.navigationController presentViewController:addVC animated:YES completion:nil];
        return;
    }
    // 点击了task model
    self.selectedCellFrame = [self.collectionView cellForItemAtIndexPath:selectedIndexPath].frame; // update selected cell frame的时机
    TimeEditingViewController *timeEditingVC = [[TimeEditingViewController alloc] initWithTaskName:selectedModel.taskName];
    timeEditingVC.transitioningDelegate = self; // 动画
    timeEditingVC.modalPresentationStyle = UIModalPresentationCustom;
    timeEditingVC.cellFrame = CGRectMake(self.collectionView.frame.origin.x + self.selectedCellFrame.origin.x, self.collectionView.frame.origin.y + self.selectedCellFrame.origin.y  - self.collectionView.contentOffset.y, self.selectedCellFrame.size.width, self.selectedCellFrame.size.height);
    [self presentViewController:timeEditingVC animated:YES completion:nil];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MirrorTaskModel *taskModel = [MirrorStorage tasksWithoutArchiveWithAddNew][indexPath.item];
    // 如果在计时中，先打开计时页面
    if (!taskModel.isAddTaskModel && [[MirrorStorage isGoingOnTask] isEqualToString:taskModel.taskName]) { // this task is ongoing
        TimeTrackingViewController * timeTrackingVC = [[TimeTrackingViewController alloc] initWithTaskName:taskModel.taskName];
        timeTrackingVC.transitioningDelegate = self;
        timeTrackingVC.modalPresentationStyle = UIModalPresentationCustom;
        timeTrackingVC.cellFrame = CGRectMake(self.collectionView.frame.origin.x + self.selectedCellFrame.origin.x, self.collectionView.frame.origin.y + self.selectedCellFrame.origin.y - self.collectionView.contentOffset.y, self.selectedCellFrame.size.width, self.selectedCellFrame.size.height);
        [self presentViewController:timeTrackingVC animated:NO completion:nil]; // present time tracking vc 一定是通过 time editing vc 结束来的，所以不需要动画。
    }
    
    if (taskModel.isAddTaskModel) {
        TimeTrackerAddTaskCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[TimeTrackerAddTaskCollectionViewCell identifier] forIndexPath:indexPath];
        [cell setupAddTaskCell];
        return cell;
    } else {
        TimeTrackerTaskCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[TimeTrackerTaskCollectionViewCell identifier] forIndexPath:indexPath];
        [cell configWithTaskname:taskModel.taskName];
        return cell;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [MirrorStorage tasksWithoutArchiveWithAddNew].count;
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *header;
    if (kind == UICollectionElementKindSectionHeader) {
        header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
    }
    return header;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(kScreenWidth, 5); // 给collectionview一个小小的header，让第一行cell的shadow的过度更自然（没有截断的效果）
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
        [_collectionView registerClass:[UICollectionViewCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    }
    return _collectionView;
}

- (UIButton *)settingsButton
{
    if (!_settingsButton) {
        _settingsButton = [UIButton new];
        UIImage *iconImage = [[UIImage systemImageNamed:@"line.horizontal.3"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [_settingsButton setImage:[iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_settingsButton addTarget:self action:@selector(goToSettings) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingsButton;
}

- (UIButton *)editTasksButton
{
    if (!_editTasksButton) {
        _editTasksButton = [UIButton new];
        UIImage *iconImage = [[UIImage systemImageNamed:@"tray.full"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [_editTasksButton setImage:[iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_editTasksButton addTarget:self action:@selector(goToAllTasks) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editTasksButton;
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
        animation.cellFrame = CGRectMake(self.collectionView.frame.origin.x + self.selectedCellFrame.origin.x, self.collectionView.frame.origin.y -  self.collectionView.contentOffset.y + self.selectedCellFrame.origin.y, self.selectedCellFrame.size.width, self.selectedCellFrame.size.height);
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
