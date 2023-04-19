//
//  OneDayHistogram.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/5.
//

#import "OneDayHistogram.h"
#import "MirrorDataManager.h"
#import "MirrorStorage.h"
#import "HistogramCollectionViewCell.h"
#import "MirrorMacro.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>
#import "MirrorSettings.h"
#import "MirrorLanguage.h"
#import "TaskRecordViewController.h"
#import "MirrorTool.h"
static CGFloat const kCellSpacing = 14; // histogram cell左右的距离

@interface OneDayHistogram () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray<MirrorDataModel *> *data;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UILabel *emptyHintLabel;

@end
@implementation OneDayHistogram

- (instancetype)initWithDatePicker:(UIDatePicker *)datePicker
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
        self.datePicker = datePicker;
        // empty hint
        [self updateHint];
        [self addSubview:self.emptyHintLabel];
        [self.emptyHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.offset(0);
        }];
        
        // histogram
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.offset(0);
        }];
    }
    return self;
}

- (void)reloadWithDate:(NSDate *)date
{
    // 选中的那天的0:0:0
    long startTime = 0;
    NSCalendar *startGregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *startComponents = [startGregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    startComponents.timeZone = [NSTimeZone systemTimeZone];
    startComponents.hour = 0;
    startComponents.minute = 0;
    startComponents.second = 0;
    startTime = [[startGregorian dateFromComponents:startComponents] timeIntervalSince1970];
    // 选中的那天的23:59:59
    long endTime = 0;
    NSCalendar *endGregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *endComponents = [endGregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    endComponents.timeZone = [NSTimeZone systemTimeZone];
    endComponents.hour = 23;
    endComponents.minute = 59;
    endComponents.second = 59;
    endTime = [[endGregorian dateFromComponents:endComponents] timeIntervalSince1970];

    self.data = [MirrorDataManager getDataWithStart:startTime end:endTime];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
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
    [self.delegate.navigationController pushViewController:[[TaskRecordViewController alloc] initWithTaskname:self.data[indexPath.item].taskName] animated:YES];
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
    self.emptyHintLabel.text = [MirrorLanguage mirror_stringWithKey:@"no_tasks_today"];
}

- (NSMutableArray<MirrorDataModel *> *)data // 根据datePicker时时更新
{
    // 选中的那天的0:0:0
    long startTime = 0;
    NSCalendar *startGregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *startComponents = [startGregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self.datePicker.date];
    startComponents.timeZone = [NSTimeZone systemTimeZone];
    startComponents.hour = 0;
    startComponents.minute = 0;
    startComponents.second = 0;
    startTime = [[startGregorian dateFromComponents:startComponents] timeIntervalSince1970];
    // 选中的那天的23:59:59
    long endTime = 0;
    NSCalendar *endGregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *endComponents = [endGregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self.datePicker.date];
    endComponents.timeZone = [NSTimeZone systemTimeZone];
    endComponents.hour = 23;
    endComponents.minute = 59;
    endComponents.second = 59;
    endTime = [[endGregorian dateFromComponents:endComponents] timeIntervalSince1970];
    _data = [MirrorDataManager getDataWithStart:startTime end:endTime];
    return _data;
}



@end
