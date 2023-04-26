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
#import "TaskRecordViewController.h"

static CGFloat const kCellSpacing = 20; // cell之间的上下间距

@interface AllTasksViewController ()  <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, VCForTaskCellProtocol>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation AllTasksViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:MirrorTaskDeleteNotification object:nil];
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

/* VC A 上push VC B，共用一个navibar，
1. 返回（B->A）的时候，需要给A重新添加一遍navibar
2. 反悔（B->A取消）之后，需要给B重新添加一遍navibar
3. 从其他页面push A或B的时候，不存在navibar的共用，hasNavibar将一直是YES
4. VC A指的是AllTasksViewController，VC B指的是TaskRecordViewController
*/
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    BOOL hasNavibar = NO;
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:UINavigationBar.class]) {
            hasNavibar = YES;
            break;
        }
    }
    if (!hasNavibar) {
        [self.view addSubview:self.navigationController.navigationBar]; // 给需要navigationbar的vc添加navigationbar
    }
}

- (void)p_setupUI
{
    // navibar
    self.navigationController.navigationBar.hidden = NO;
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
        make.top.mas_equalTo(self.view).offset(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);
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
    [cell configWithIndex:indexPath.item];
    cell.delegate = self;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kScreenWidth - 2*kCellSpacing, 160);
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
