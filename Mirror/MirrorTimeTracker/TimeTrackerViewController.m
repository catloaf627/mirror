//
//  TimeTrackerViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/25.
//

#import "TimeTrackerViewController.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>
#import "TimeTrackerTaskCollectionViewCell.h"
#import "TimeTrackerAddTaskCollectionViewCell.h"
#import "TimeTrackerDataManager.h"
#import "MirrorDefaultDataManager.h"
#import "MirrorMacro.h"

static CGFloat const kCellSpacing = 16; // cell之间的上下间距
static CGFloat const kCollectionViewPadding = 20; // 左右留白

@interface TimeTrackerViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) TimeTrackerDataManager *dataManager;

@end

@implementation TimeTrackerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataManager.tasks = [[MirrorDefaultDataManager sharedInstance] mirrorDefaultTimeTrackerData]; //gizmo 暂时写死
    [self  p_setupUI];
}

- (void)p_setupUI
{
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view).offset(kCollectionViewPadding);
            make.right.mas_equalTo(self.view).offset(-kCollectionViewPadding);
            make.top.mas_equalTo(self.view).offset(kNavBarAndStatusBarHeight);
            make.bottom.mas_equalTo(self.view).offset(-kTabBarHeight);
    }];
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
        
        [_collectionView registerClass:[TimeTrackerTaskCollectionViewCell class] forCellWithReuseIdentifier:[TimeTrackerTaskCollectionViewCell identifier]];
        [_collectionView registerClass:[TimeTrackerAddTaskCollectionViewCell class] forCellWithReuseIdentifier:[TimeTrackerAddTaskCollectionViewCell identifier]];
        
    }
    return _collectionView;
}

# pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)selectedIndexPath
{
    // 点击了add task model [+]
    TimeTrackerTaskModel *selectedModel = self.dataManager.tasks[selectedIndexPath.item];
    if (selectedModel.isAddTaskModel) {
        return;
    }
    
    // 点击了task model
    TimeTrackerTaskCollectionViewCell *selectedCell = (TimeTrackerTaskCollectionViewCell *)[collectionView cellForItemAtIndexPath:selectedIndexPath];
    if (selectedCell.isAnimating) { // 点击了正在计时的selectedCell，停止selectedCell的计时
        [selectedCell stopAnimation];
    } else { // 点击了未开始计时的selectedCell，停止所有其他计时cell，再开始selectedCell的计时
        for (int i=0; i<self.dataManager.tasks.count; i++) {
            TimeTrackerTaskCollectionViewCell *cell = (TimeTrackerTaskCollectionViewCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if ([cell respondsToSelector:@selector(stopAnimation)]) { // 因为循环的时候也会循环到[+]，[+]并没有stopAnimation方法，这里控制一下，避免崩溃
                [cell stopAnimation];
            }
        }
        [selectedCell startAnimation];
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TimeTrackerTaskModel *taskModel = self.dataManager.tasks[indexPath.item];
    if (taskModel.isAddTaskModel) {
        TimeTrackerAddTaskCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[TimeTrackerAddTaskCollectionViewCell identifier] forIndexPath:indexPath];
        [cell setupAddTaskCell];
        return cell;
    } else {
        TimeTrackerTaskCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[TimeTrackerTaskCollectionViewCell identifier] forIndexPath:indexPath];
        [cell configWithModel:taskModel];
        return cell;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataManager.tasks.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((kScreenWidth - kCollectionViewPadding - kCollectionViewPadding -kCellSpacing)/2, 90);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kCellSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kCellSpacing;
}

#pragma mark - Getters
- (TimeTrackerDataManager *)dataManager
{
    if (!_dataManager) {
        _dataManager = [[TimeTrackerDataManager alloc]init];
    }
    return _dataManager;
}


@end
