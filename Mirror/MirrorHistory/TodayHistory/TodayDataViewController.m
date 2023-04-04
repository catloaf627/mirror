//
//  TodayDataViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/4.
//

#import "TodayDataViewController.h"
#import "UIColor+MirrorColor.h"
#import "MirrorTabsManager.h"
#import "TimeTrackerDataManager.h"
#import "TodayDataCollectionViewCell.h"
#import "MirrorMacro.h"
#import <Masonry/Masonry.h>

static CGFloat const kCellSpacing = 20; // cell之间的上下间距

typedef NS_ENUM(NSInteger, DataSectionType) {
    DataSectionTypeActivated,
    DataSectionTypeArchived,
};

@interface TodayDataViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) TimeTrackerDataManager *dataManager;

@end

@implementation TodayDataViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadVC) name:@"MirrorSwitchThemeNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadVC) name:@"MirrorSwitchLanguageNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadVC) name:@"MirrorSwitchImmersiveModeNotification" object:nil];
    }
    return self;
}

- (void)reloadVC
{
    // 将vc.view里的所有subviews全部置为nil
    self.collectionView = nil;
    // 将vc.view里的所有subviews从父view上移除
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 更新tab item
    [MirrorTabsManager updateHistoryTabItemWithTabController:self.tabBarController];
    [self viewDidLoad];
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

- (void)viewDidAppear:(BOOL)animated
{
    [self.collectionView reloadData];
}

- (void)p_setupUI
{
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kCellSpacing);
        make.right.mas_equalTo(self.view).offset(-kCellSpacing);
        make.top.mas_equalTo(self.view).offset(kNavBarAndStatusBarHeight);
        make.bottom.mas_equalTo(self.view).offset(-kTabBarHeight);
    }];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == DataSectionTypeActivated) { // non-archived tasks
        return self.dataManager.activatedTasks.count;
    } else if (section == DataSectionTypeArchived) { // archived tasks
        return self.dataManager.archivedTasks.count;
    } else {
        return 0;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TodayDataCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[TodayDataCollectionViewCell identifier] forIndexPath:indexPath];
    if (indexPath.section == DataSectionTypeActivated) {
        [cell configCellWithModel:self.dataManager.activatedTasks[indexPath.item]];
    } else if (indexPath.section ==  DataSectionTypeArchived) {
        [cell configCellWithModel:self.dataManager.archivedTasks[indexPath.item]];
    }
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
    }
    return header;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(kScreenWidth, 10);
}


#pragma mark - Getters

- (TimeTrackerDataManager *)dataManager
{
    if (!_dataManager) {
        _dataManager = [TimeTrackerDataManager new];
    }
    return _dataManager;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = self.view.backgroundColor;
        
        [_collectionView registerClass:[TodayDataCollectionViewCell class] forCellWithReuseIdentifier:[TodayDataCollectionViewCell identifier]];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    }
    return _collectionView;
}


@end
