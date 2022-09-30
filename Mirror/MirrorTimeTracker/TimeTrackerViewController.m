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
#import "TimeTrackerDataManager.h"
#import "MirrorDefaultDataManager.h"
#import "MirrorMacro.h"
#import "MirrorTabsManager.h"
#import "EditTaskViewController.h"
#import "AddTaskViewController.h"

static CGFloat const kCellSpacing = 16; // cell之间的上下间距
static CGFloat const kCollectionViewPadding = 20; // 左右留白

@interface TimeTrackerViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, EditTaskProtocol, AddTaskProtocol>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) TimeTrackerDataManager *dataManager;

@end

@implementation TimeTrackerViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadVC) name:@"MirrorSwitchThemeNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadVC) name:@"MirrorSwitchLanguageNotification" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadVC
{
    // 将vc.view里的所有subviews全部置为nil
    self.collectionView = nil;
    // 将vc.view里的所有subviews从父view上移除
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 更新tab item
    [MirrorTabsManager updateTimeTabItemWithTabController:self.tabBarController];
    [self viewDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataManager.tasks = [[MirrorDefaultDataManager sharedInstance] mirrorDefaultTimeTrackerData]; //gizmo 暂时写死
    [self  p_setupUI];
}

- (void)p_setupUI
{
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view).offset(kCollectionViewPadding);
            make.right.mas_equalTo(self.view).offset(-kCollectionViewPadding);
            make.top.mas_equalTo(self.view).offset(kNavBarAndStatusBarHeight);
            make.bottom.mas_equalTo(self.view).offset(-kTabBarHeight);
    }];
}

#pragma mark - Actions

// double click开始计时/停止计时
- (void)cellGetDoubleClicked:(UITapGestureRecognizer *)doubleTapRecognizer
{
    CGPoint touchPoint = [doubleTapRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
    if (indexPath == nil) {
        return;
    }
    TimeTrackerTaskModel *task = self.dataManager.tasks[indexPath.item];
    if (task.isAddTaskModel) {
        return;
    }
    
    // 点击了task model
    TimeTrackerTaskModel *selectedModel = self.dataManager.tasks[indexPath.item];
    if (selectedModel.isOngoing) { // 点击了正在计时的selectedCell，停止selectedCell的计时
        selectedModel.isOngoing = NO;
    } else { // 点击了未开始计时的selectedCell，停止所有其他计时cell，再开始selectedCell的计时
        for (int i=0; i<self.dataManager.tasks.count; i++) {
            TimeTrackerTaskModel *model = self.dataManager.tasks[i];
            if ([model respondsToSelector:@selector(setIsOngoing:)]) { // 因为循环的时候也会循环到[+]，[+]并没有isOngoing属性，这里控制一下，避免崩溃
                model.isOngoing = NO;
            }
        }
        selectedModel.isOngoing = YES;
    }
    [self.collectionView reloadData];
}


// swipe唤起task编辑页面
- (void)cellGetSwiped:(UISwipeGestureRecognizer *)swipeRecognizer
{
    CGPoint touchPoint = [swipeRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
    if (indexPath == nil) {
        return;
    }
    TimeTrackerTaskModel *task = self.dataManager.tasks[indexPath.item];
    if (task.isAddTaskModel) {
        return;
    }
    EditTaskViewController *editVC = [[EditTaskViewController alloc]initWithTasks:self.dataManager.tasks[indexPath.item]];
    editVC.delegate = self;
    [self.navigationController presentViewController:editVC animated:YES completion:nil];
}

// long press唤起编辑顺序
- (void)cellGetLongPressed:(UILongPressGestureRecognizer *)longPressRecognizer
{
    CGPoint touchPoint = [longPressRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
    if (indexPath == nil) {
        return;
    }
    TimeTrackerTaskModel *task = self.dataManager.tasks[indexPath.item];
    if (task.isAddTaskModel) {
        return;
    }
    switch (longPressRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self.collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
            break;
        case UIGestureRecognizerStateChanged:
            [self.collectionView updateInteractiveMovementTargetPosition:[longPressRecognizer locationInView:self.collectionView]];
            break;
        case UIGestureRecognizerStateEnded:
            [self.collectionView endInteractiveMovement];
            break;
        default:
            [self.collectionView cancelInteractiveMovement];
            break;
    }
}

# pragma mark - EditTaskProtocol

- (void)updateTasks
{
    [self.collectionView reloadData];
}

- (void)deleteTask:(TimeTrackerTaskModel *)model
{
    NSMutableArray<TimeTrackerTaskModel *> *tasks = [self.dataManager.tasks mutableCopy];
    [tasks removeObject:model];
    // 如果删除完了一个task后发现，最后一个元素不是[+]，且此时数量不足kMaxTaskNum，在尾部添加[+]
    if (!tasks[tasks.count-1].isAddTaskModel && tasks.count < kMaxTaskNum) {
        [tasks insertObject:[[TimeTrackerTaskModel alloc]initWithTitle:nil colorType:nil isAddTask:YES] atIndex:tasks.count];
    }
    self.dataManager.tasks = tasks;
    [self.collectionView reloadData];
}

# pragma mark - AddTaskProtocol

- (void)addNewTask:(TimeTrackerTaskModel *)newTask
{
    NSMutableArray<TimeTrackerTaskModel *> *tasks = [self.dataManager.tasks mutableCopy];
    if (tasks[tasks.count-1].isAddTaskModel) { //如果最后一个元素是add task
        [tasks insertObject:newTask atIndex:tasks.count-1]; //插入最后一个元素之前
    } else {
        [tasks insertObject:newTask atIndex:tasks.count]; //插入队伍最后
    }
    // 如果添加完了一个task后发现，包括[+]数量超过了kMaxTaskNum，这个时候删掉最后的[+]
    if (tasks.count > kMaxTaskNum) {
        tasks = [[tasks subarrayWithRange:NSMakeRange(0, kMaxTaskNum)] mutableCopy];
    }
    
    self.dataManager.tasks = tasks;
    [self.collectionView reloadData];
}

# pragma mark - Collection view delegate

// 轻点[+]
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)selectedIndexPath
{
    TimeTrackerTaskModel *selectedModel = self.dataManager.tasks[selectedIndexPath.item];
    if (selectedModel.isAddTaskModel) {
        AddTaskViewController *addVC = [AddTaskViewController new];
        addVC.delegate = self;
        [self.navigationController presentViewController:addVC animated:YES completion:nil];
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TimeTrackerTaskModel *taskModel = self.dataManager.tasks[indexPath.item];
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
    return self.dataManager.tasks.count;
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

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSMutableArray *tasks = [self.dataManager.tasks mutableCopy];
    TimeTrackerTaskModel *taskModel = tasks[sourceIndexPath.item];
    [tasks removeObjectAtIndex:sourceIndexPath.item];
    [tasks insertObject:taskModel atIndex:destinationIndexPath.item];
    self.dataManager.tasks = tasks;
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
        
        // 双击手势
        UITapGestureRecognizer *tapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellGetDoubleClicked:)];
        tapRecogniser.numberOfTapsRequired = 2;
        [_collectionView addGestureRecognizer:tapRecogniser];
        
        // 滑动手势
        UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellGetSwiped:)];
        swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft;
        [_collectionView addGestureRecognizer:swipeRecognizer];
        
        // 长按手势
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(cellGetLongPressed:)];
        longPressRecognizer.minimumPressDuration = 1;
        [_collectionView addGestureRecognizer:longPressRecognizer];
    }
    return _collectionView;
}

- (TimeTrackerDataManager *)dataManager
{
    if (!_dataManager) {
        _dataManager = [[TimeTrackerDataManager alloc]init];
    }
    return _dataManager;
}

@end
