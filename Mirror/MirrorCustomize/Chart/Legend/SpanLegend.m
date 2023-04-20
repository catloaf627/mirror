//
//  SpanLegend.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/20.
//

#import "SpanLegend.h"
#import "MirrorDataManager.h"
#import <Masonry/Masonry.h>
#import "MirrorSettings.h"
#import "MirrorStorage.h"
#import "LegendCollectionViewCell.h"
#import "TaskRecordViewController.h"
#import "MirrorTool.h"

static CGFloat const kCellHeight = 30; // 一个legend的高度
static NSInteger const kNumOfCellPerRow = 3; // 一行固定放三个cell

@interface SpanLegend () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray<MirrorDataModel *> *data;

@property (nonatomic, assign) NSInteger spanType;
@property (nonatomic, assign) NSInteger offset;

@end


@implementation SpanLegend

- (instancetype)initWithSpanType:(SpanType)spanType offset:(NSInteger)offset
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
        self.layer.cornerRadius = 14;
        self.spanType = spanType;
        self.offset = offset;
        // legend
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.offset(0);
        }];
    }
    return self;
}

- (void)updateWithSpanType:(SpanType)spanType offset:(NSInteger)offset
{
    self.spanType = spanType;
    self.offset = offset;
    [self.collectionView reloadData];
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

- (NSMutableArray<MirrorDataModel *> *)data
{
    // span开始那天的0:0:0
    long startTime = 0;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate now]];
    components.timeZone = [NSTimeZone systemTimeZone];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    if (self.spanType == SpanTypeWeek) {
        long todayZero = [[gregorian dateFromComponents:components] timeIntervalSince1970];
        startTime = todayZero - [MirrorTool getDayGapFromTheFirstDayThisWeek] * 86400;
        if (self.offset != 0) {
            startTime = startTime + 7*86400*self.offset;
        }
    } else if (self.spanType == SpanTypeMonth) {
        components.day = 1;
        if (self.offset > 0) {
            for (int i=0;i<self.offset;i++) {
                if (components.month + 1 <= 12) {
                    components.month = components.month + 1;
                } else {
                    components.year = components.year + 1;
                    components.month = 1;
                }
            }
        }
        if (self.offset < 0) {
            for (int i=0;i<-self.offset;i++) {
                if (components.month - 1 >= 1) {
                    components.month = components.month - 1;
                } else {
                    components.year = components.year - 1;
                    components.month = 12;
                }
            }
        }
        startTime = [[gregorian dateFromComponents:components] timeIntervalSince1970];
    } else if (self.spanType == SpanTypeYear) {
        components.month = 1;
        components.day = 1;
        if (self.offset != 0) {
            components.year = components.year + self.offset;
        }
        startTime = [[gregorian dateFromComponents:components] timeIntervalSince1970];
    }
    
    
    // span结束那天的23:59:59
    long endTime = 0;
    if (self.spanType == SpanTypeWeek) {
        NSInteger numberOfDaysInWeek= 7;
        endTime = startTime + numberOfDaysInWeek*86400 - 1;
    } else if (self.spanType == SpanTypeMonth) {
        NSRange rng = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[NSDate dateWithTimeIntervalSince1970:startTime]];
        NSInteger numberOfDaysInMonth = rng.length;
        endTime = startTime + numberOfDaysInMonth*86400 - 1;
    } else if (self.spanType == SpanTypeYear) {
        NSRange rng = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:[NSDate dateWithTimeIntervalSince1970:startTime]];
        NSInteger numberOfDaysIYear = rng.length;
        endTime = startTime + numberOfDaysIYear*86400 - 1;
    }
    
    _data = [MirrorDataManager getDataWithStart:startTime end:endTime];
    return _data;
}


@end
