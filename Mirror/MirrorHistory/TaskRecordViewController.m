//
//  TaskRecordViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/15.
//

#import "TaskRecordViewController.h"
#import <Masonry/Masonry.h>
//#import "MirrorTabsManager.h"
#import "UIColor+MirrorColor.h"
#import "MirrorDataManager.h"
#import "MirrorMacro.h"
#import "TaskPeriodCollectionViewCell.h"
#import "MirrorStorage.h"
static CGFloat const kCellSpacing = 20; // cell之间的上下间距

@interface TaskRecordViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) MirrorDataModel *task;

@end

@implementation TaskRecordViewController

- (instancetype)initWithTaskname:(NSString *)taskName
{
    self = [super init];
    if (self) {
        self.task = [MirrorStorage getTaskFromDB:taskName];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_setupUI];
}

- (void)p_setupUI
{
    // navibar
    self.navigationController.navigationBar.barTintColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground]; // navibar颜色为背景色
    self.navigationController.navigationBar.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText]; // 返回箭头颜色为文案颜色
    [self.navigationItem setTitle:self.task.taskName]; // title为taskname
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor mirrorColorNamed:MirrorColorTypeText] forKey:NSForegroundColorAttributeName]; // title为文案颜色

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
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.task.periods.count == 0) return 0;
    BOOL theLastPeriodIsFinished = self.task.periods[self.task.periods.count-1].count == 2;
    return self.task.periods.count - (theLastPeriodIsFinished ? 0:1);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TaskPeriodCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[TaskPeriodCollectionViewCell identifier] forIndexPath:indexPath];
    [cell configWithStart:[self.task.periods[indexPath.item][0] longValue] end:[self.task.periods[indexPath.item][1] longValue] color:[UIColor mirrorColorNamed:self.task.color]];
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
        layout.minimumLineSpacing = 10;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = self.view.backgroundColor;
        
        [_collectionView registerClass:[TaskPeriodCollectionViewCell class] forCellWithReuseIdentifier:[TaskPeriodCollectionViewCell identifier]];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    }
    return _collectionView;
}


@end

