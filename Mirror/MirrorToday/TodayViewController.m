//
//  TodayViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/4.
//

#import "TodayViewController.h"
#import "MirrorTabsManager.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>
#import "MirrorMacro.h"
#import "MirrorSettings.h"
#import "LeftAnimation.h"
#import "SettingsViewController.h"
#import "MirrorPiechart.h"
#import "MirrorLanguage.h"
#import "TodayPeriodCollectionViewCell.h"
#import "MirrorDataManager.h"
#import "PeriodsTotalHeaderCell.h"

static CGFloat const kLeftRightSpacing = 20;
static CGFloat const kCellSpacing = 20; // cell之间的上下间距

@interface TodayViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, EditPeriodForTodayProtocol, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;

@property (nonatomic, strong) UIView *todayView;
@property (nonatomic, strong) UILabel *todayLabel;
@property (nonatomic, strong) UILabel *todayDateLabel;
@property (nonatomic, strong) MirrorPiechart *pieChart;
@property (nonatomic, strong) UIButton *crownButton;

@property (nonatomic, strong) UICollectionView *collectionView;
// 下面两个都是数据源，同步更新
@property (nonatomic, strong) NSMutableArray<NSString *> *tasknames;
@property (nonatomic, strong) NSMutableArray *originIndexes;

@end

@implementation TodayViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartVC) name:MirrorSwitchThemeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartVC) name:MirrorSwitchLanguageNotification object:nil];
        
        // 数据通知 (直接数据驱动UI，本地数据变动必然导致这里的UI变动)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskStopNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskEditNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskDeleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskArchiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskCreateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorPeriodDeleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorPeriodEditNotification object:nil];
    }
    return self;
}

- (void)restartVC
{
    // 将vc.view里的所有subviews全部置为nil
    self.settingsButton = nil;
    self.todayView = nil;
    self.todayLabel = nil;
    self.todayDateLabel = nil;
    self.pieChart = nil;
    self.crownButton = nil;
    self.collectionView = nil;
    // 将vc.view里的所有subviews从父view上移除
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 更新tabbar
    [[MirrorTabsManager sharedInstance] updateDataTabItemWithTabController:self.tabBarController];
    [self viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)reloadData
{
    // 当页面没有出现在屏幕上的时候reloaddata不会触发UICollectionViewDataSource的几个方法，所以需要上面viewWillAppear做一个兜底。
    [self.pieChart updateTodayWithWidth:80];
    [self.collectionView reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    [self p_setupUI];
}

- (void)p_setupUI
{
    /*
     If a custom bar button item is not specified by either of the view controllers, a default back button is used and its title is set to the value of the title property of the previous view controller—that is, the view controller one level down on the stack.
     */
    self.navigationController.navigationBar.topItem.title = @""; //给父vc一个空title，让所有子vc的navibar返回文案都为空
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    
    [self.view addSubview:self.todayView];
    [self.todayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);
        make.centerX.offset(0);
        make.height.mas_equalTo(100);
    }];
    [self.todayView addSubview:self.todayLabel];
    [self.todayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
        make.centerY.offset(-10);
    }];
    [self.todayView addSubview:self.crownButton];
    [self.crownButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.todayLabel.mas_left);
        make.centerY.mas_equalTo(self.todayLabel.mas_top);
        make.width.height.mas_equalTo(25);
    }];
    [self.todayView addSubview:self.todayDateLabel];
    [self.todayDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.todayLabel.mas_bottom);
        make.left.offset(0);
    }];
    [self.todayView addSubview:self.pieChart];
    [self.pieChart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.mas_equalTo(self.todayDateLabel.mas_right).offset(20);
        make.width.height.mas_equalTo(80);
        make.right.offset(0);
    }];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.todayView.mas_bottom);
        make.left.offset(kLeftRightSpacing);
        make.right.offset(-kLeftRightSpacing);
        make.bottom.offset(-kTabBarHeight);
    }];

    [self.view addSubview:self.settingsButton];
    [self.settingsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kLeftRightSpacing);
        make.bottom.mas_equalTo(self.self.todayView.mas_top);
        make.width.height.mas_equalTo(40);
    }];
    UIScreenEdgePanGestureRecognizer *edgeRecognizer = [UIScreenEdgePanGestureRecognizer new];
    edgeRecognizer.edges = UIRectEdgeLeft;
    [edgeRecognizer addTarget:self action:@selector(edgeGestureRecognizerAction:)];
    [self.view addGestureRecognizer:edgeRecognizer];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    [self updateDataSource];
    return self.tasknames.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateDataSource];
    TodayPeriodCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[TodayPeriodCollectionViewCell identifier] forIndexPath:indexPath];
    [cell configWithTaskname:self.tasknames[indexPath.item] periodIndex:[self.originIndexes[indexPath.item] integerValue]];
    cell.delegate = self;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kScreenWidth - 2*kCellSpacing, 80);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *header;
    if (kind == UICollectionElementKindSectionHeader) {
        header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        [(PeriodsTotalHeaderCell *)header configWithTasknames:self.tasknames periodIndexes:self.originIndexes];
    }
    return header;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(kScreenWidth, 30);
}

#pragma mark - Actions

- (void)crownAnimation
{
    [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy] impactOccurred];
    [UIView animateKeyframesWithDuration:0.1 delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
        self.crownButton.transform = CGAffineTransformMakeRotation(-M_PI/4-0.2); //左
    } completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:0.1 delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
            self.crownButton.transform = CGAffineTransformMakeRotation(-M_PI/4+0.2); //右
        } completion:^(BOOL finished) {
            [UIView animateKeyframesWithDuration:0.1 delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
                self.crownButton.transform = CGAffineTransformMakeRotation(-M_PI/4-0.2); //左
            } completion:^(BOOL finished) {
                [UIView animateKeyframesWithDuration:0.1 delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
                    self.crownButton.transform = CGAffineTransformMakeRotation(-M_PI/4+0.2); //右
                } completion:^(BOOL finished) {
                    self.crownButton.transform = CGAffineTransformMakeRotation(-M_PI/4); //恢复
                }];
            }];
        }];
    }];
}

#pragma mark - Getters

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 10;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = self.view.backgroundColor;
        
        [_collectionView registerClass:[TodayPeriodCollectionViewCell class] forCellWithReuseIdentifier:[TodayPeriodCollectionViewCell identifier]];
        [_collectionView registerClass:[PeriodsTotalHeaderCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
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

- (UIView *)todayView
{
    if (!_todayView) {
        _todayView = [UIView new];
    }
    return _todayView;
}

- (UILabel *)todayLabel
{
    if (!_todayLabel) {
        _todayLabel = [UILabel new];
        _todayLabel.text =[MirrorLanguage mirror_stringWithKey:@"today"];
        _todayLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:37];
        _todayLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
    }
    return _todayLabel;
}

- (UILabel *)todayDateLabel
{
    if (!_todayDateLabel) {
        _todayDateLabel = [UILabel new];
        _todayDateLabel.text = [self dayFromDateWithWeekday:[NSDate now]];
        _todayDateLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:17];
        _todayDateLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeCellGrayPulse]; // 和nickname的文字颜色保持一致
    }
    return _todayDateLabel;
}

- (MirrorPiechart *)pieChart
{
    if (!_pieChart) {
        _pieChart = [[MirrorPiechart alloc] initTodayWithWidth:80];
    }
    return _pieChart;
}


- (UIButton *)crownButton
{
    if (!_crownButton) {
        _crownButton = [UIButton new];
        UIImage *iconImage = [[UIImage systemImageNamed:@"crown.fill"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [_crownButton setImage:[iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _crownButton.transform = CGAffineTransformMakeRotation(-M_PI/4);
        _crownButton.tintColor = [UIColor systemYellowColor];
        [_crownButton addTarget:self action:@selector(crownAnimation) forControlEvents:UIControlEventTouchUpInside];
    }
    return _crownButton;
}

- (void)updateDataSource
{
    self.tasknames = nil;
    self.originIndexes = nil;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate now]];
    components.timeZone = [NSTimeZone systemTimeZone];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    long startTime = [[gregorian dateFromComponents:components] timeIntervalSince1970];
    long endTime = startTime + 86400 - 1;
    
    NSArray *allTasks = [MirrorDataManager allTasks];
    for (int i=0; i<allTasks.count; i++) {
        MirrorDataModel *task = allTasks[i];
        for (NSInteger periodIndex=0; periodIndex<task.periods.count; periodIndex++) {
            NSArray *period = task.periods[periodIndex];
            if ([period[0] longValue] >= startTime && [period[0] longValue] <= endTime) { // 符合要求，可以展示在today页面
                [self.tasknames addObject:task.taskName];
                [self.originIndexes addObject:@(periodIndex)];
            }
        }
    }
}

- (NSMutableArray<NSString *> *)tasknames
{
    if (!_tasknames) {
        _tasknames = [NSMutableArray new];
    }
    return _tasknames;
}

- (NSMutableArray<NSArray *> *)originIndexes
{
    if (!_originIndexes) {
        _originIndexes = [NSMutableArray new];
    }
    return _originIndexes;
}

#pragma mark - Settings

- (void)goToSettings
{
    [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight] impactOccurred];
    SettingsViewController * settingsVC = [[SettingsViewController alloc] init];
    settingsVC.transitioningDelegate = self;
    settingsVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:settingsVC animated:YES completion:nil];
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


#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    LeftAnimation *animation = [LeftAnimation new];
    animation.isPresent = YES;
    return animation;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return self.interactiveTransition;
}

#pragma mark - Privates

- (NSString *)dayFromDateWithWeekday:(NSDate *)date
{
    // setup
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:date];
    components.timeZone = [NSTimeZone systemTimeZone];
    // details
    long year = (long)components.year;
    long month = (long)components.month;
    long day = (long)components.day;
    long week = (long)components.weekday;
    
    NSString *weekday = @"";
    if (week == 1) weekday = [MirrorLanguage mirror_stringWithKey:@"sunday"];
    if (week == 2) weekday = [MirrorLanguage mirror_stringWithKey:@"monday"];
    if (week == 3) weekday = [MirrorLanguage mirror_stringWithKey:@"tuesday"];
    if (week == 4) weekday = [MirrorLanguage mirror_stringWithKey:@"wednesday"];
    if (week == 5) weekday = [MirrorLanguage mirror_stringWithKey:@"thursday"];
    if (week == 6) weekday = [MirrorLanguage mirror_stringWithKey:@"friday"];
    if (week == 7) weekday = [MirrorLanguage mirror_stringWithKey:@"saturday"];
    return [NSString stringWithFormat: @"%ld.%ld.%ld, %@", year, month, day, weekday];
}



@end
