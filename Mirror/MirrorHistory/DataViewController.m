//
//  DataViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/4.
//

#import "DataViewController.h"
#import "MirrorTabsManager.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>
#import "MirrorMacro.h"
#import "DataEntranceCollectionViewCell.h"
#import "MirrorHistogram.h"
#import "MirrorLegend.h"
#import "MirrorSettings.h"

static CGFloat const kLeftRightSpacing = 20;
static CGFloat const kCellSpacing = 20;

@interface DataViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MirrorLegendDelegate, MirrorHistogramDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) MirrorLegend *legendView;
@property (nonatomic, strong) MirrorHistogram *histogramView;

@end

@implementation DataViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartVC) name:MirrorSwitchThemeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartVC) name:MirrorSwitchLanguageNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartVC) name:MirrorSwitchWeekStartsOnNotification object:nil]; // 比其他vc多监听一个week starts on通知
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

- (void)restartVC
{
    // 将vc.view里的所有subviews全部置为nil
    self.collectionView = nil;
    self.legendView = nil;
    self.histogramView = nil;
    // 将vc.view里的所有subviews从父view上移除
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 更新tab item
    [[MirrorTabsManager sharedInstance] updateHistoryTabItemWithTabController:self.tabBarController];
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
    [self.collectionView reloadData];
    [self.legendView.collectionView reloadData];
    [self.legendView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([self.legendView legendViewHeight]);
    }];
    [self.histogramView.collectionView reloadData];
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
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kLeftRightSpacing);
        make.right.mas_equalTo(self.view).offset(-kLeftRightSpacing);
        make.top.mas_equalTo(self.view).offset(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);
        make.height.mas_equalTo(80 * 2 + 20); // 两行cell加上他们的行间距
    }];
    [self.view addSubview:self.legendView];
    [self.legendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kLeftRightSpacing);
        make.right.mas_equalTo(self.view).offset(-kLeftRightSpacing);
        make.top.mas_equalTo(self.collectionView.mas_bottom).offset(20);
        make.height.mas_equalTo([self.legendView legendViewHeight]);
    }];
    [self.view addSubview:self.histogramView];
    [self.histogramView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kLeftRightSpacing);
        make.right.mas_equalTo(self.view).offset(-kLeftRightSpacing);
        make.top.mas_equalTo(self.legendView.mas_bottom).offset(20);
        make.bottom.mas_equalTo(self.view).offset(-kTabBarHeight - 20);
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DataEntranceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[DataEntranceCollectionViewCell identifier] forIndexPath:indexPath];
    DataEntranceType type = DataEntranceTypeToday;
    if (indexPath.item == 0) type = DataEntranceTypeToday;
    if (indexPath.item == 1) type = DataEntranceTypeThisWeek;
    if (indexPath.item == 2) type = DataEntranceTypeThisMonth;
    if (indexPath.item == 3) type = DataEntranceTypeThisYear;
    [cell configCellWithType:type];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((kScreenWidth - 3*kCellSpacing)/2, 80);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.item) {
        case 0:
            [MirrorSettings userSetPreferredHistogramType:UserPreferredHistogramTypeToday];
            [self reloadData];
            break;
            
        case 1:
            [MirrorSettings userSetPreferredHistogramType:UserPreferredHistogramTypeThisWeek];
            [self reloadData];
            break;
            
        case 2:
            [MirrorSettings userSetPreferredHistogramType:UserPreferredHistogramTypeThisMonth];
            [self reloadData];
            break;
            
        case 3:
            [MirrorSettings userSetPreferredHistogramType:UserPreferredHistogramTypeThisYear];
            [self reloadData];
            break;
            
        default:
            break;
    }
}

#pragma mark - Getters

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 20;
        layout.minimumInteritemSpacing = 20;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = self.view.backgroundColor;
        
        [_collectionView registerClass:[DataEntranceCollectionViewCell class] forCellWithReuseIdentifier:[DataEntranceCollectionViewCell identifier]];
    }
    return _collectionView;
}

- (MirrorHistogram *)histogramView
{
    if (!_histogramView) {
        _histogramView = [MirrorHistogram new];
        _histogramView.delegate = self;
    }
    return _histogramView;
}

- (MirrorLegend *)legendView
{
    if (!_legendView) {
        _legendView = [MirrorLegend new];
        _legendView.delegate = self;
    }
    return _legendView;
}


@end
