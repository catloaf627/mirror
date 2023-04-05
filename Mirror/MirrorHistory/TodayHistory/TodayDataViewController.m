//
//  TodayDataViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/4.
//

#import "TodayDataViewController.h"
#import "UIColor+MirrorColor.h"
#import "MirrorTabsManager.h"
#import "MirrorDataManager.h"
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

@end

@implementation TodayDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_setupUI];
}

- (void)p_setupUI
{
    // navibar
    self.navigationController.navigationBar.barTintColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground]; // navibar颜色为背景色
    self.navigationController.navigationBar.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText]; // 返回箭头颜色为文案颜色
    self.navigationController.navigationBar.shadowImage = [UIImage new]; // navibar底部1pt下划线隐藏
    [self.view addSubview:self.navigationController.navigationBar]; // 给需要navigationbar的vc添加navigationbar
    // collection view
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kCellSpacing);
        make.right.mas_equalTo(self.view).offset(-kCellSpacing);
        make.top.mas_equalTo(self.navigationController.navigationBar.mas_bottom);
        make.bottom.mas_equalTo(self.view);
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
        return [MirrorDataManager activatedTasks].count;
    } else if (section == DataSectionTypeArchived) { // archived tasks
        return [MirrorDataManager archivedTasks].count;
    } else {
        return 0;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TodayDataCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[TodayDataCollectionViewCell identifier] forIndexPath:indexPath];
    if (indexPath.section == DataSectionTypeActivated) {
        [cell configCellWithModel:[MirrorDataManager activatedTasks][indexPath.item]];
    } else if (indexPath.section ==  DataSectionTypeArchived) {
        [cell configCellWithModel:[MirrorDataManager archivedTasks][indexPath.item]];
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
