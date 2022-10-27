//
//  HistoryViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/25.
//

#import "HistoryViewController.h"
#import "UIColor+MirrorColor.h"
#import "MirrorTabsManager.h"
#import "TimeTrackerDataManager.h"
#import "TaskDataCollectionViewCell.h"
#import "MirrorMacro.h"
#import <Masonry/Masonry.h>

typedef NS_ENUM(NSInteger, DataSectionType) {
    DataSectionTypeActivated,
    DataSectionTypeArchived,
};

@interface HistoryViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) TimeTrackerDataManager *dataManager;

@end

@implementation HistoryViewController

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

- (void)p_setupUI
{
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.mas_equalTo(self.view).offset(0);
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
    TaskDataCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[TaskDataCollectionViewCell identifier] forIndexPath:indexPath];
    if (indexPath.section == DataSectionTypeActivated) {
        [cell configCellWithModel:self.dataManager.activatedTasks[indexPath.item]];
    } else if (indexPath.section ==  DataSectionTypeArchived) {
        [cell configCellWithModel:self.dataManager.archivedTasks[indexPath.item]];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kScreenWidth, 80);
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
        
        [_collectionView registerClass:[TaskDataCollectionViewCell class] forCellWithReuseIdentifier:[TaskDataCollectionViewCell identifier]];
    }
    return _collectionView;
}


@end
