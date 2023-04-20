//
//  SpanHistogram.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/20.
//

#import "SpanHistogram.h"
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

@interface SpanHistogram () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray<MirrorDataModel *> *data;
@property (nonatomic, strong) UILabel *emptyHintLabel;

@property (nonatomic, assign) NSInteger spanType;
@property (nonatomic, assign) NSInteger offset;

@end

@implementation SpanHistogram

- (instancetype)initWithSpanType:(SpanType)spanType offset:(NSInteger)offset
{
    self = [super init];
    if (self) {
        self.spanType = spanType;
        self.offset = offset;
        self.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
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

- (void)updateWithSpanType:(SpanType)spanType offset:(NSInteger)offset
{
    self.spanType = spanType;
    self.offset = offset;
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
//    self.emptyHintLabel.text = [MirrorLanguage mirror_stringWithKey:@"no_tasks_on_day" with1Placeholder:[self dayFromDate:self.datePicker.date]];
    self.emptyHintLabel.hidden = self.data.count > 0;
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
        startTime = todayZero - [MirrorTool getDayGapFromTheFirstDayThisWeek] * 86400;// now所在周的第一天的0:0:0
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
        startTime = [[gregorian dateFromComponents:components] timeIntervalSince1970];// now所在月的第一天的0:0:0
    } else if (self.spanType == SpanTypeYear) {
        components.month = 1;
        components.day = 1;
        if (self.offset != 0) {
            components.year = components.year + self.offset;
        }
        startTime = [[gregorian dateFromComponents:components] timeIntervalSince1970];// now所在月的第一天的0:0:0
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
    // update label
    [self.delegate updateStartDate:[self dayFromDateWithWeekday:[NSDate dateWithTimeIntervalSince1970:startTime]] endDate:[self dayFromDateWithWeekday:[NSDate dateWithTimeIntervalSince1970:endTime]]];
    return _data;
}

- (NSString *)dayFromDateWithWeekday:(NSDate *)date
{
    // setup
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:date];
    components.timeZone = [NSTimeZone systemTimeZone];
    // details
    long year = (long)components.year;
    long month = (long)components.month;
    long day = (long)components.day;
    long week = (long)components.weekday;
    
    NSString *weekday = @"";
    if (week == 1) weekday = [MirrorLanguage mirror_stringWithKey:@"sunday"];
    if (week == 2) weekday = [MirrorLanguage mirror_stringWithKey:@"monday"];
    if (week == 3) weekday = [MirrorLanguage mirror_stringWithKey:@"tuesday"];
    if (week == 4) weekday = [MirrorLanguage mirror_stringWithKey:@"wednesday"];
    if (week == 5) weekday = [MirrorLanguage mirror_stringWithKey:@"thursday"];
    if (week == 6) weekday = [MirrorLanguage mirror_stringWithKey:@"friday"];
    if (week == 7) weekday = [MirrorLanguage mirror_stringWithKey:@"saturday"];
    return [NSString stringWithFormat: @"%ld.%ld.%ld, %@", year, month, day, weekday];
}

- (NSString *)dayFromDate:(NSDate *)date
{
    // setup
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    components.timeZone = [NSTimeZone systemTimeZone];
    // details
    long year = (long)components.year;
    long month = (long)components.month;
    long day = (long)components.day;
    
    return [NSString stringWithFormat: @"%ld.%ld.%ld", year, month, day];
}



@end
