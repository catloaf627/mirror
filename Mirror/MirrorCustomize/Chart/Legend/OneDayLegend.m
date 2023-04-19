//
//  OneDayLegend.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/15.
//

#import "OneDayLegend.h"
#import "MirrorDataManager.h"
#import <Masonry/Masonry.h>
#import "MirrorSettings.h"
#import "MirrorStorage.h"
#import "LegendCollectionViewCell.h"
#import "TaskRecordViewController.h"

static CGFloat const kCellHeight = 30; // 一个legend的高度
static NSInteger const kNumOfCellPerRow = 3; // 一行固定放三个cell

@interface OneDayLegend () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray<MirrorDataModel *> *data;
@property (nonatomic, strong) UIDatePicker *datePicker;

@end

@implementation OneDayLegend

- (instancetype)initWithDatePicker:(UIDatePicker *)datePicker
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
        self.layer.cornerRadius = 14;
        self.datePicker = datePicker;
        // legend
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.offset(0);
        }];
    }
    return self;
}

- (CGFloat)legendViewHeight
{
    return (self.data.count/kNumOfCellPerRow + ((self.data.count%kNumOfCellPerRow) ? 1:0)) * kCellHeight;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.data.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LegendCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LegendCollectionViewCell identifier] forIndexPath:indexPath];
    [cell configCellWithTask:self.data[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth = self.bounds.size.width / kNumOfCellPerRow;
    return CGSizeMake(cellWidth, kCellHeight);
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
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[LegendCollectionViewCell class] forCellWithReuseIdentifier:[LegendCollectionViewCell identifier]];
    }
    return _collectionView;
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
