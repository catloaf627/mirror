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
#import "DataHistogramCollectionViewCell.h"
// 跳转
#import "TodayDataViewController.h"

static CGFloat const kLeftRightSpacing = 20;
static CGFloat const kCellSpacing = 20;

@interface DataViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
// 数据源为本地数据

@end

@implementation DataViewController

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
        make.left.mas_equalTo(self.view).offset(kLeftRightSpacing);
        make.right.mas_equalTo(self.view).offset(-kLeftRightSpacing);
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
    if (section == 0) {
        return 4; // Today, This month, This year, All data
    }
    if (section == 1) {
        return 1; // histogram (default: Today)
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        DataEntranceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[DataEntranceCollectionViewCell identifier] forIndexPath:indexPath];
        [cell configCellWithIndex:indexPath.item];
        return cell;
    } else {
        DataHistogramCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[DataHistogramCollectionViewCell identifier] forIndexPath:indexPath];
        [cell configCell];
        return cell;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return CGSizeMake((kScreenWidth - 3*kCellSpacing)/2, 80);
    } else {
        return CGSizeMake(kScreenWidth - 2*kCellSpacing, 120);
    }
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

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0) {
        return;
    }
    switch (indexPath.item) {
        case 0:
            [self.navigationController pushViewController:[TodayDataViewController new] animated:YES];
            break;
            
        case 1:
            
            break;
            
        case 2:
            
            break;
            
        case 3:
            
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
        [_collectionView registerClass:[DataHistogramCollectionViewCell class] forCellWithReuseIdentifier:[DataHistogramCollectionViewCell identifier]];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    }
    return _collectionView;
}




@end
