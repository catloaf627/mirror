//
//  EditTasksViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/26.
//

#import "EditTasksViewController.h"
#import "MirrorMacro.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>
#import "MirrorDataManager.h"
#import "EditTaskCollectionViewCell.h"
#import "TaskRecordViewController.h"
#import "MirrorLanguage.h"
#import "MirrorNaviManager.h"

static CGFloat const kCellSpacing = 20; // cell之间的上下间距

@interface EditTasksViewController ()  <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, VCForTaskCellProtocol>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation EditTasksViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskDeleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskChangeOrderNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorPeriodDeleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorPeriodEditNotification object:nil];
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
    [[MirrorNaviManager sharedInstance] updateNaviItemWithTitle:@"" naviController:self.navigationController leftButton:nil rightButton:nil];
    self.navigationController.navigationBar.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText]; // 返回箭头颜色为文案颜色
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor mirrorColorNamed:MirrorColorTypeText] forKey:NSForegroundColorAttributeName]; // title为文案颜色
    [self.navigationItem setTitle:[MirrorLanguage mirror_stringWithKey:@"edit_tasks"]];
    // collection view
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kCellSpacing);
        make.right.mas_equalTo(self.view).offset(-kCellSpacing);
        make.top.mas_equalTo(self.view).offset(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);
        make.bottom.mas_equalTo(self.view);
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[UIApplication sharedApplication].windows.firstObject endEditing: YES];
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
    EditTaskCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[EditTaskCollectionViewCell identifier] forIndexPath:indexPath];
    [cell configWithIndex:indexPath.item];
    cell.delegate = self;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kScreenWidth - 2*kCellSpacing, 160);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *footer;
    if (kind == UICollectionElementKindSectionFooter) {
        footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];
    }
    return footer;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(kScreenWidth, kScreenHeight / 2); // 给collectionview一个大大的footer，最后一个cell在被编辑的时候可以被拖动到keyboard以上
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
        [_collectionView registerClass:[EditTaskCollectionViewCell class] forCellWithReuseIdentifier:[EditTaskCollectionViewCell identifier]];
        [_collectionView registerClass:[UICollectionViewCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
    }
    return _collectionView;
}

@end
