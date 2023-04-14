//
//  MirrorHistogram.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/5.
//

#import "MirrorHistogram.h"
#import "MirrorDataManager.h"
#import "MirrorStorage.h"
#import "HistogramCollectionViewCell.h"
#import "MirrorMacro.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>
#import "MirrorSettings.h"

static CGFloat const kCellSpacing = 14; // histogram cell左右的距离

@interface MirrorHistogram () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray<MirrorDataModel *> *data;

@end
@implementation MirrorHistogram

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
        self.layer.cornerRadius = 14;
        self.collectionView.layer.cornerRadius = 14;
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.offset(0);
        }];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch ([MirrorSettings userPreferredHistogramType]) {
        case MirrorHistogramTypeToday:
            self.data = [MirrorDataManager getDataWithStart:[MirrorStorage startedTimeToday] end:[[NSDate now] timeIntervalSince1970]];
            break;
        case MirrorHistogramTypeThisWeek:
            self.data = [MirrorDataManager getDataWithStart:[MirrorStorage startedTimeThisWeek] end:[[NSDate now] timeIntervalSince1970]];
            break;
        case MirrorHistogramTypeThisMonth:
            self.data = [MirrorDataManager getDataWithStart:[MirrorStorage startedTimeThisMonth] end:[[NSDate now] timeIntervalSince1970]];
            break;
        case MirrorHistogramTypeThisYear:
            self.data = [MirrorDataManager getDataWithStart:[MirrorStorage startedTimeThisYear] end:[[NSDate now] timeIntervalSince1970]];
            break;
    }
    return self.data.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HistogramCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[HistogramCollectionViewCell identifier] forIndexPath:indexPath];
    [cell configCellWithData:self.data index:indexPath.item];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = self.data.count;
    if (count > 0) {
        CGFloat width = (self.bounds.size.width - (count - 1)*kCellSpacing) / count;
        return CGSizeMake(width, self.bounds.size.height);
    } else {
        return CGSizeMake(self.bounds.size.width, self.bounds.size.height);
    }

}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - Getters

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 14;
        layout.minimumInteritemSpacing = 14;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
        [_collectionView registerClass:[HistogramCollectionViewCell class] forCellWithReuseIdentifier:[HistogramCollectionViewCell identifier]];
    }
    return _collectionView;
}

@end
