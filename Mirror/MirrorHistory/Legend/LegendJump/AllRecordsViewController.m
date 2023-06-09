//
//  AllRecordsViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/5.
//

/* DEBUG 专用VC*/

#import "AllRecordsViewController.h"
#import <Masonry/Masonry.h>
#import "UIColor+MirrorColor.h"
#import "MirrorMacro.h"
#import "TaskPeriodCollectionViewCell.h"
#import "MirrorStorage.h"
#import "MirrorLanguage.h"
#import "MirrorNaviManager.h"

static CGFloat const kCellSpacing = 20; // cell之间的上下间距

@interface AllRecordsViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, VCForPeriodCellProtocol>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL isStartedScroll;
@property (nonatomic, assign) BOOL isFinishedScroll;

@end

@implementation AllRecordsViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartVC) name:MirrorSwitchThemeNotification object:nil];
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

- (void)restartVC
{
    // update navibar
    [[MirrorNaviManager sharedInstance] updateNaviItemWithNaviController:self.navigationController title:[MirrorLanguage mirror_stringWithKey:@"all_records"] leftButton:nil rightButton:nil];
    // 将vc.view里的所有subviews全部置为nil
    self.collectionView = nil;
    // 将vc.view里的所有subviews从父view上移除
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self  p_setupUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[MirrorNaviManager sharedInstance] updateNaviItemWithNaviController:self.navigationController title:[MirrorLanguage mirror_stringWithKey:@"all_records"] leftButton:nil rightButton:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_setupUI];
}

- (void)p_setupUI
{
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
    return [MirrorStorage retriveMirrorRecords].count;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_scrollToIndex && indexPath.item == 0 && !_isStartedScroll) { // 展示第0个的时候scroll（一次生命周期只走一次）
        _isStartedScroll = YES;
        [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[_scrollToIndex integerValue] inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    }
    if (_scrollToIndex && indexPath.item == [_scrollToIndex integerValue] && !_isFinishedScroll) { // 展示第selected个的时候闪烁（一次生命周期只走一次）
        _isFinishedScroll = YES;
        MirrorRecordModel *record = [MirrorStorage retriveMirrorRecords][[_scrollToIndex integerValue]];
        MirrorTaskModel *task = [MirrorStorage getTaskModelFromDB:record.taskName];
        UIColor *color = [UIColor mirrorColorNamed:task.color];
        UIColor *pulseColor = [UIColor mirrorColorNamed:[UIColor mirror_getPulseColorType:task.color]];
        [UIView animateWithDuration:0.5 animations:^{
            cell.backgroundColor = pulseColor;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                cell.backgroundColor = color;
            } completion:^(BOOL finished) {}];
        }];
    }

}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TaskPeriodCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[TaskPeriodCollectionViewCell identifier] forIndexPath:indexPath];
    MirrorRecordModel *record = [MirrorStorage retriveMirrorRecords][indexPath.item];
    [cell configWithTaskname:record.taskName periodIndex:indexPath.item type:BottomRightTypeName];
    cell.delegate = self;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kScreenWidth - 2*kCellSpacing, 80);
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
    }
    return _collectionView;
}

- (void)updateUIAfterDeleteDataAtIndex:(NSInteger)index {
    
}

@end
