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
#import "MirrorLanguage.h"

static CGFloat const kCellSpacing = 14; // histogram cell左右的距离

@interface MirrorHistogram () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray<MirrorDataModel *> *data;
@property (nonatomic, strong) UILabel *emptyHintLabel;

@end
@implementation MirrorHistogram

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
        self.layer.cornerRadius = 14;
        
        // empty hint
        [self updateHint];
        [self addSubview:self.emptyHintLabel];
        [self.emptyHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.offset(0);
        }];
        
        // histogram
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
        case UserPreferredHistogramTypeToday:
            self.data = [MirrorDataManager getDataWithStart:[MirrorStorage startedTimeToday] end:[[NSDate now] timeIntervalSince1970]];
            break;
        case UserPreferredHistogramTypeThisWeek:
            self.data = [MirrorDataManager getDataWithStart:[MirrorStorage startedTimeThisWeek] end:[[NSDate now] timeIntervalSince1970]];
            break;
        case UserPreferredHistogramTypeThisMonth:
            self.data = [MirrorDataManager getDataWithStart:[MirrorStorage startedTimeThisMonth] end:[[NSDate now] timeIntervalSince1970]];
            break;
        case UserPreferredHistogramTypeThisYear:
            self.data = [MirrorDataManager getDataWithStart:[MirrorStorage startedTimeThisYear] end:[[NSDate now] timeIntervalSince1970]];
            break;
    }
    [self updateHint]; // reloaddata要顺便reload一下emptyhint的状态
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
    if (self.data.count == 0) return CGSizeZero;
    if (self.data.count >= 4) { // 4,5,6...
        CGFloat cellWidth = (self.bounds.size.width - (self.data.count - 1)*kCellSpacing) / self.data.count;
        return CGSizeMake(cellWidth, self.bounds.size.height);
    } else { // 1,2,3
        CGFloat cellWidth = (self.bounds.size.width - (4 - 1)*kCellSpacing) / 4;
        return CGSizeMake(cellWidth, self.bounds.size.height);
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *view = nil;
    if ([kind isEqualToString:@"UICollectionElementKindSectionHeader"]) {
        UICollectionViewCell *headerView = [collectionView   dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        return headerView;
    }
    if ([kind isEqualToString:@"UICollectionElementKindSectionFooter"]) {
        UICollectionViewCell *footerView = [collectionView   dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];
        return footerView;
    }
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (self.data.count == 0) return CGSizeZero;
    if (self.data.count >= 4) { // 4,5,6...
        return CGSizeMake(0, 0);
    } else {  // 1,2,3
        CGFloat cellWidth = (self.bounds.size.width - (4 - 1 )*kCellSpacing) / 4;
        CGFloat width = cellWidth * self.data.count + kCellSpacing * (self.data.count-1);
        return CGSizeMake((self.bounds.size.width - width)/2, self.bounds.size.height);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (self.data.count == 0) return CGSizeZero;
    if (self.data.count >= 4 ) { // 4,5,6...
        return CGSizeMake(0, 0);
    } else {  // 1,2,3
        CGFloat cellWidth = (self.bounds.size.width - (4 - 1)*kCellSpacing) / 4;
        CGFloat width = cellWidth * self.data.count + kCellSpacing * (self.data.count-1);
        return CGSizeMake((self.bounds.size.width - width)/2, self.bounds.size.height);
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
        _collectionView.backgroundColor = [UIColor clearColor]; // 设置为透明色，可以将后面的emptyhint露出来
        [_collectionView registerClass:[HistogramCollectionViewCell class] forCellWithReuseIdentifier:[HistogramCollectionViewCell identifier]];

        [_collectionView registerClass:[UICollectionViewCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
        [_collectionView registerClass:[UICollectionViewCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
    }
    return _collectionView;
}

- (UILabel *)emptyHintLabel
{
    if (!_emptyHintLabel) {
        _emptyHintLabel = [UILabel new];
        _emptyHintLabel.textAlignment = NSTextAlignmentCenter;
        _emptyHintLabel.text = @"";
        _emptyHintLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:16];
        _emptyHintLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeCellGrayPulse]; // 和nickname的文字颜色保持一致
    }
    return _emptyHintLabel;
}

- (void)updateHint
{
    self.emptyHintLabel.hidden = self.data.count > 0;
    if ([MirrorSettings userPreferredHistogramType] == UserPreferredHistogramTypeToday) {
        self.emptyHintLabel.text = [MirrorLanguage mirror_stringWithKey:@"no_tasks_today"];
    }
    if ([MirrorSettings userPreferredHistogramType] == UserPreferredHistogramTypeThisWeek) {
        self.emptyHintLabel.text = [MirrorLanguage mirror_stringWithKey:@"no_tasks_this_week"];
    }
    if ([MirrorSettings userPreferredHistogramType] == UserPreferredHistogramTypeThisMonth) {
        self.emptyHintLabel.text = [MirrorLanguage mirror_stringWithKey:@"no_tasks_this_month"];
    }
    if ([MirrorSettings userPreferredHistogramType] == UserPreferredHistogramTypeThisYear) {
        self.emptyHintLabel.text = [MirrorLanguage mirror_stringWithKey:@"no_tasks_this_year"];
    }
}

@end
