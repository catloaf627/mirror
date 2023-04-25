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
#import "MirrorTimeText.h"

static CGFloat const kCellSpacing = 14; // histogram cell左右的距离

// 5-6的时候自适应是最好看的，小于5按照5取size（有header/footer padding），大于6按照5.5取size（右侧展示出来半个cell，提示用户需要滚动才能看全）
static NSInteger const kPrettyCountMin = 5;
static NSInteger const kPrettyCountMax = 6;
static CGFloat const kPrettyCountShowHalf = 5.5;

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
    if (self.data.count < kPrettyCountMin) {
        CGFloat cellWidth = (self.bounds.size.width - (kPrettyCountMin - 1)*kCellSpacing) / kPrettyCountMin;
        return CGSizeMake(cellWidth, self.bounds.size.height);
    } else if (self.data.count >= kPrettyCountMin && self.data.count <= kPrettyCountMax) {
        CGFloat cellWidth = (self.bounds.size.width - (self.data.count - 1)*kCellSpacing) / self.data.count;
        return CGSizeMake(cellWidth, self.bounds.size.height);
    } else {
        CGFloat cellWidth = (self.bounds.size.width - [@(kPrettyCountShowHalf) integerValue]*kCellSpacing) / kPrettyCountShowHalf;
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
    if (self.data.count < kPrettyCountMin) {
        CGFloat cellWidth = (self.bounds.size.width - (kPrettyCountMin - 1 )*kCellSpacing) / kPrettyCountMin;
        CGFloat width = cellWidth * self.data.count + kCellSpacing * (self.data.count-1);
        return CGSizeMake((self.bounds.size.width - width)/2, self.bounds.size.height);
    } else {
        return CGSizeMake(0, 0);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (self.data.count == 0) return CGSizeZero;
    if (self.data.count < kPrettyCountMin) {
        CGFloat cellWidth = (self.bounds.size.width - (kPrettyCountMin - 1)*kCellSpacing) / kPrettyCountMin;
        CGFloat width = cellWidth * self.data.count + kCellSpacing * (self.data.count-1);
        return CGSizeMake((self.bounds.size.width - width)/2, self.bounds.size.height);
    } else {
        return CGSizeMake(0, 0);
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
    self.emptyHintLabel.text = [MirrorLanguage mirror_stringWithKey:@"no_data"];
    self.emptyHintLabel.hidden = self.data.count > 0;
}

- (NSMutableArray<MirrorDataModel *> *)data
{
    long startTime = 0;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate now]];
    components.timeZone = [NSTimeZone systemTimeZone];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    if (self.spanType == SpanTypeDay) {
        startTime = [[gregorian dateFromComponents:components] timeIntervalSince1970];
        if (self.offset != 0) {
            startTime = startTime + 86400*self.offset;
        }
    } else if (self.spanType == SpanTypeWeek) {
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
    
    long endTime = 0;
    if (self.spanType == SpanTypeDay) {
        endTime = startTime + 86400;
    } else if (self.spanType == SpanTypeWeek) {
        NSInteger numberOfDaysInWeek= 7;
        endTime = startTime + numberOfDaysInWeek*86400;
    } else if (self.spanType == SpanTypeMonth) {
        NSRange rng = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[NSDate dateWithTimeIntervalSince1970:startTime]];
        NSInteger numberOfDaysInMonth = rng.length;
        endTime = startTime + numberOfDaysInMonth*86400;
    } else if (self.spanType == SpanTypeYear) {
        NSRange rng = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:[NSDate dateWithTimeIntervalSince1970:startTime]];
        NSInteger numberOfDaysIYear = rng.length;
        endTime = startTime + numberOfDaysIYear*86400;
    }
    
    _data = [MirrorDataManager getDataWithStart:startTime end:endTime];
    // update label
    NSString *startDate = [MirrorTimeText YYYYmmddWeekday:[NSDate dateWithTimeIntervalSince1970:startTime]];
    NSString *endDate = [MirrorTimeText YYYYmmddWeekday:[NSDate dateWithTimeIntervalSince1970:endTime-1]];// 这里减1是因为，period本身在读的时候取的是左闭右开，例如2023.4.17,Mon,00:00 - 2023.4.19,Wed,00:00间隔为2天，指的就是2023.4.17, 2023.4.18这两天，2023.4.19本身是不做数的。因此这里传日期的时候要减去1，将结束时间2023.4.19,Wed,00:00改为2023.4.18,Wed,23:59，这样传过去的label就只展示左闭右开区间里真实囊括的两天了。
    
    if ([startDate isEqualToString:endDate]) {
        [self.delegate updateSpanText:startDate];
    } else {
        startDate = [MirrorTimeText YYYYmmdd:[NSDate dateWithTimeIntervalSince1970:startTime]];
        endDate = [MirrorTimeText YYYYmmdd:[NSDate dateWithTimeIntervalSince1970:endTime-1]];
        NSString *combine  = [[startDate stringByAppendingString:@" - "] stringByAppendingString:endDate];
        [self.delegate updateSpanText:combine];
    }
    return _data;
}

@end
