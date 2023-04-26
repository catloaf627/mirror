//
//  AllTasksViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/26.
//

#import "AllTasksViewController.h"
#import "MirrorMacro.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>
#import "MirrorDataManager.h"
#import "TaskInfoCollectionViewCell.h"

static CGFloat const kCellSpacing = 20; // cell之间的上下间距

@interface AllTasksViewController ()  <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation AllTasksViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskEditNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadData
{
    [self.collectionView reloadData];
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
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor mirrorColorNamed:MirrorColorTypeText] forKey:NSForegroundColorAttributeName]; // title为文案颜色
    [self.navigationItem setTitle:@"All tasks"];
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
    return [MirrorDataManager allTasks].count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TaskInfoCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[TaskInfoCollectionViewCell identifier] forIndexPath:indexPath];
    [cell configWithTaskname:[MirrorDataManager allTasks][indexPath.item].taskName];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kScreenWidth - 2*kCellSpacing, 80);
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 10;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = self.view.backgroundColor;
        [_collectionView registerClass:[TaskInfoCollectionViewCell class] forCellWithReuseIdentifier:[TaskInfoCollectionViewCell identifier]];
    }
    return _collectionView;
}

@end
