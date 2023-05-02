//
//  GridViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/5/2.
//

#import "GridViewController.h"
#import <Masonry/Masonry.h>
#import "MirrorNaviManager.h"
#import "UIColor+MirrorColor.h"
#import "GridCollectionViewCell.h"
#import "MirrorMacro.h"
#import "MirrorLanguage.h"
#import "MirrorDataModel.h"
#import "MirrorDataManager.h"
#import "MirrorStorage.h"
#import "MirrorSettings.h"
#import "GridComponent.h"
#import "SpanLegend.h"
#import "MirrorPiechart.h"
#import "MirrorTimeText.h"
#import "MirrorTool.h"

static CGFloat const kLeftRightSpacing = 20;
static CGFloat const kCellWidth = 30;
static CGFloat const kCellSpacing = 3;

@interface GridViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIView *weekdayView;
@property (nonatomic, strong) SpanLegend *legendView;
@property (nonatomic, strong) MirrorPiechart *piechartView;
@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, assign) NSInteger startTimestamp;
@property (nonatomic, assign) NSInteger selectedCellIndex;
@property (nonatomic, assign) MirrorColorType randomColorType;

@end

@implementation GridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_setupUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[MirrorNaviManager sharedInstance] updateNaviItemWithNaviController:self.navigationController title:[MirrorLanguage mirror_stringWithKey:@"activities"] leftButton:nil rightButton:nil];
}


- (void)p_setupUI
{
    // collection view
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    [self.view addSubview:self.weekdayView];
    [self.weekdayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kLeftRightSpacing);
        make.top.mas_equalTo(self.view).offset(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);
        make.height.mas_equalTo(kCellWidth*7 + kCellSpacing*6);
        make.width.mas_equalTo(kCellWidth);
    }];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.weekdayView.mas_right).offset(kCellSpacing);
        make.right.mas_equalTo(self.view).offset(-kLeftRightSpacing);
        make.top.mas_equalTo(self.view).offset(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);
        make.height.mas_equalTo(kCellWidth*7 + kCellSpacing*6);
    }];
    [self.view addSubview:self.dateLabel];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kLeftRightSpacing);
        make.right.mas_equalTo(self.view).offset(-kLeftRightSpacing);
        make.top.mas_equalTo(self.collectionView.mas_bottom).offset(20);
        make.height.mas_equalTo(20);
    }];
    [self.view addSubview:self.legendView];
    [self.legendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kLeftRightSpacing);
        make.right.mas_equalTo(self.view).offset(-kLeftRightSpacing);
        make.top.mas_equalTo(self.dateLabel.mas_bottom).offset(20);
        make.height.mas_equalTo([self.legendView legendViewHeight]);
    }];
    [self.view addSubview:self.piechartView];
    CGFloat width = MIN([[self leftWidthLeftHeight][0] floatValue], [[self leftWidthLeftHeight][1] floatValue]);
    [self.piechartView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (width == [[self leftWidthLeftHeight][0] floatValue]) { // 宽度小于高度
            make.top.mas_equalTo(self.legendView.mas_bottom).offset(10 + ([[self leftWidthLeftHeight][1] floatValue]-[[self leftWidthLeftHeight][0] floatValue])/2);
            make.centerX.offset(0);
            make.width.height.mas_equalTo(width);
        } else {
            make.top.mas_equalTo(self.legendView.mas_bottom).offset(10);
            make.centerX.offset(0);
            make.width.height.mas_equalTo(width);
        }
    }];
    NSString *iconName = [MirrorSettings appliedShowShade] ? @"square.grid.2x2.fill" : @"square.grid.2x2";
    UIImage *image = [[UIImage systemImageNamed:iconName] imageWithTintColor:[UIColor mirrorColorNamed:MirrorColorTypeText]];
    UIImage *imageWithRightColor = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *shadeItem = [[UIBarButtonItem alloc]  initWithImage:imageWithRightColor style:UIBarButtonItemStylePlain target:self action:@selector(switchShadeType)];
    shadeItem.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
    [self.navigationItem setRightBarButtonItem:shadeItem];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == _selectedCellIndex) {
        _selectedCellIndex = NSIntegerMin; // 取消选择
    } else {
        _selectedCellIndex = indexPath.item; // 选择
    }
    long timestamp = _startTimestamp + indexPath.item * 86400;
    NSMutableArray<MirrorDataModel *> *data = [MirrorDataManager getDataWithStart:timestamp end:timestamp+86400];
    long totaltime = 0;
    for (MirrorDataModel* task in data) {
        totaltime = totaltime + [MirrorTool getTotalTimeOfPeriods:task.periods];
    }
    self.dateLabel.text = [[[MirrorTimeText YYYYmmddWeekday:[NSDate dateWithTimeIntervalSince1970:timestamp]] stringByAppendingString:@". "] stringByAppendingString:[MirrorTimeText XdXhXmXsFull:totaltime]];
    [self.legendView updateWithData:data];
    [self.legendView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([self.legendView legendViewHeight]);
    }];
    CGFloat width = MIN([[self leftWidthLeftHeight][0] floatValue], [[self leftWidthLeftHeight][1] floatValue]);
    [self.piechartView updateWithData:data width:width enableInteractive:YES];
    [self.piechartView mas_updateConstraints:^(MASConstraintMaker *make) {
        if (width == [[self leftWidthLeftHeight][0] floatValue]) { // 宽度小于高度
            make.top.mas_equalTo(self.legendView.mas_bottom).offset(10 + ([[self leftWidthLeftHeight][1] floatValue]-[[self leftWidthLeftHeight][0] floatValue])/2);
            make.width.height.mas_equalTo(width);
        } else {
            make.top.mas_equalTo(self.legendView.mas_bottom).offset(10);
            make.width.height.mas_equalTo(width);
        }
    }];
    [collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return  self.data.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GridCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[GridCollectionViewCell identifier] forIndexPath:indexPath];
    NSInteger targetTimestamp = _startTimestamp + indexPath.item * 86400;
    GridComponent *grid = self.data[[@(targetTimestamp) stringValue]];
    BOOL isSelected = indexPath.item==_selectedCellIndex;
    [cell configWithGridComponent:grid isSelected:isSelected];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kCellWidth, kCellWidth);
}



#pragma mark - Getters

- (SpanLegend *)legendView
{
    if (!_legendView) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate now]];
        components.timeZone = [NSTimeZone systemTimeZone];
        components.hour = 0;
        components.minute = 0;
        components.second = 0;
        long timestamp = [[gregorian dateFromComponents:components] timeIntervalSince1970];
        _legendView = [[SpanLegend alloc] initWithData:[MirrorDataManager getDataWithStart:timestamp end:timestamp+86400]];
    }
    return _legendView;
}

- (MirrorPiechart *)piechartView
{
    if (!_piechartView) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate now]];
        components.timeZone = [NSTimeZone systemTimeZone];
        components.hour = 0;
        components.minute = 0;
        components.second = 0;
        long timestamp = [[gregorian dateFromComponents:components] timeIntervalSince1970];
        CGFloat width = MIN([[self leftWidthLeftHeight][0] floatValue], [[self leftWidthLeftHeight][1] floatValue]);
        _piechartView = [[MirrorPiechart alloc] initWithData:[MirrorDataManager getDataWithStart:timestamp end:timestamp+86400] width:width enableInteractive:YES];
    }
    return _piechartView;
}

- (UILabel *)dateLabel
{
    if (!_dateLabel) {
        _dateLabel = [UILabel new];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.text = [MirrorTimeText YYYYmmddWeekday:[NSDate now]];
        _dateLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:16];
        _dateLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText]; // 和nickname的文字颜色保持一致
    }
    return _dateLabel;
}

- (UIView *)weekdayView
{
    if (!_weekdayView) {
        _weekdayView = [UIView new];
        BOOL appliedWeekStarsOnMonday = [MirrorSettings appliedWeekStarsOnMonday];
        UIColor *textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
        UILabel *day0 = [UILabel new];
        day0.adjustsFontSizeToFitWidth = YES;
        day0.text = appliedWeekStarsOnMonday ? [MirrorLanguage mirror_stringWithKey:@"monday"] : [MirrorLanguage mirror_stringWithKey:@"sunday"];
        day0.textColor = textColor;
        day0.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:16];
        [_weekdayView addSubview:day0];
        [day0 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.offset(0);
            make.top.offset(0);
            make.height.offset(kCellWidth);
        }];
        UILabel *day1 = [UILabel new];
        day1.adjustsFontSizeToFitWidth = YES;
        day1.text = appliedWeekStarsOnMonday ? [MirrorLanguage mirror_stringWithKey:@"tuesday"] : [MirrorLanguage mirror_stringWithKey:@"monday"];
        day1.textColor = textColor;
        day1.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:16];
        [_weekdayView addSubview:day1];
        [day1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.offset(0);
            make.top.mas_equalTo(day0.mas_bottom).offset(kCellSpacing);
            make.height.offset(kCellWidth);
        }];
        UILabel *day2 = [UILabel new];
        day2.adjustsFontSizeToFitWidth = YES;
        day2.text = appliedWeekStarsOnMonday ? [MirrorLanguage mirror_stringWithKey:@"wednesday"] : [MirrorLanguage mirror_stringWithKey:@"tuesday"];
        day2.textColor = textColor;
        day2.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:16];
        [_weekdayView addSubview:day2];
        [day2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.offset(0);
            make.top.mas_equalTo(day1.mas_bottom).offset(kCellSpacing);
            make.height.offset(kCellWidth);
        }];
        UILabel *day3 = [UILabel new];
        day3.adjustsFontSizeToFitWidth = YES;
        day3.text = appliedWeekStarsOnMonday ? [MirrorLanguage mirror_stringWithKey:@"thursday"] : [MirrorLanguage mirror_stringWithKey:@"wednesday"];
        day3.textColor = textColor;
        day3.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:16];
        [_weekdayView addSubview:day3];
        [day3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.offset(0);
            make.top.mas_equalTo(day2.mas_bottom).offset(kCellSpacing);
            make.height.offset(kCellWidth);
        }];
        UILabel *day4 = [UILabel new];
        day4.adjustsFontSizeToFitWidth = YES;
        day4.text = appliedWeekStarsOnMonday ? [MirrorLanguage mirror_stringWithKey:@"friday"] : [MirrorLanguage mirror_stringWithKey:@"thursday"];
        day4.textColor = textColor;
        day4.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:16];
        [_weekdayView addSubview:day4];
        [day4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.offset(0);
            make.top.mas_equalTo(day3.mas_bottom).offset(kCellSpacing);
            make.height.offset(kCellWidth);
        }];
        UILabel *day5 = [UILabel new];
        day5.adjustsFontSizeToFitWidth = YES;
        day5.text = appliedWeekStarsOnMonday ? [MirrorLanguage mirror_stringWithKey:@"saturday"] : [MirrorLanguage mirror_stringWithKey:@"friday"];
        day5.textColor = textColor;
        day5.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:16];
        [_weekdayView addSubview:day5];
        [day5 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.offset(0);
            make.top.mas_equalTo(day4.mas_bottom).offset(kCellSpacing);
            make.height.offset(kCellWidth);
        }];
        UILabel *day6 = [UILabel new];
        day6.adjustsFontSizeToFitWidth = YES;
        day6.text = appliedWeekStarsOnMonday ? [MirrorLanguage mirror_stringWithKey:@"sunday"] : [MirrorLanguage mirror_stringWithKey:@"saturday"];
        day6.textColor = textColor;
        day6.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:16];
        [_weekdayView addSubview:day6];
        [day6 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.offset(0);
            make.top.mas_equalTo(day5.mas_bottom).offset(kCellSpacing);
            make.height.offset(kCellWidth);
        }];
        
    }
    return _weekdayView;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = kCellSpacing;
        layout.minimumInteritemSpacing = kCellSpacing;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = self.view.backgroundColor;
        [_collectionView registerClass:[GridCollectionViewCell class] forCellWithReuseIdentifier:[GridCollectionViewCell identifier]];
    }
    return _collectionView;
}

- (void)switchShadeType
{
    [MirrorSettings switchShowShade];
    NSString *iconName = [MirrorSettings appliedShowShade] ? @"square.grid.2x2.fill" : @"square.grid.2x2";
    UIImage *image = [[UIImage systemImageNamed:iconName] imageWithTintColor:[UIColor mirrorColorNamed:MirrorColorTypeText]];
    UIImage *imageWithRightColor = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *shadeItem = [[UIBarButtonItem alloc]  initWithImage:imageWithRightColor style:UIBarButtonItemStylePlain target:self action:@selector(switchShadeType)];
    shadeItem.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
    [self.navigationItem setRightBarButtonItem:shadeItem];
    NSArray *allColorType = @[@(MirrorColorTypeCellPink), @(MirrorColorTypeCellOrange), @(MirrorColorTypeCellYellow), @(MirrorColorTypeCellGreen), @(MirrorColorTypeCellTeal), @(MirrorColorTypeCellBlue), @(MirrorColorTypeCellPurple),@(MirrorColorTypeCellGray)];
    self.randomColorType = [allColorType[arc4random() % allColorType.count] integerValue]; // 随机生成一个颜色
    [MirrorSettings changePreferredShadeColor:self.randomColorType];
    [self.collectionView reloadData];
}

- (MirrorColorType)randomColorType
{
    if (!_randomColorType) {
        _randomColorType = [MirrorSettings preferredShadeColor];
    }
    return _randomColorType;
}


// key是00:00的timestamp，value是GridComponent
- (NSMutableDictionary *)data
{
    if (!_data) {
        _data = [NSMutableDictionary new];
        NSMutableDictionary *mirrorDict = [MirrorStorage retriveMirrorData];
        NSInteger minTimestamp = NSIntegerMax;
        NSInteger maxTimestamp = NSIntegerMin;
        for (id key in mirrorDict.allKeys) {
            MirrorDataModel *task = mirrorDict[key];
            for (int i=0; i<task.periods.count; i++) {
                NSInteger timestamp = [task.periods[i][0] integerValue];
                if (task.periods[i].count == 2 && timestamp < minTimestamp) {
                    minTimestamp = timestamp;
                }
                if (task.periods[i].count == 2 && timestamp > maxTimestamp) {
                    maxTimestamp = timestamp;
                }
            }
        }
        // 2023.5.1 3:00 到 2023.5.3 19:00 算三天
        if (maxTimestamp != NSIntegerMin && minTimestamp != NSIntegerMax) { // 有 有效数据
            if (maxTimestamp < [[NSDate now] timeIntervalSince1970]) {
                maxTimestamp = [[NSDate now] timeIntervalSince1970]; // 如果现存最晚任务也在今天之前，设置最大时间为今天。
            }
            NSDate *minDate = [NSDate dateWithTimeIntervalSince1970:minTimestamp];
            NSDate *maxDate = [NSDate dateWithTimeIntervalSince1970:maxTimestamp];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *minComponents = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:minDate];
            minComponents.timeZone = [NSTimeZone systemTimeZone];
            NSDateComponents *maxComponents = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:maxDate];
            maxComponents.timeZone = [NSTimeZone systemTimeZone];
            
            minComponents.hour = 0;
            minComponents.minute = 0;
            minComponents.second = 0;
            maxComponents.hour = 0;
            maxComponents.minute = 0;
            maxComponents.second = 0;
            
            minDate = [gregorian dateFromComponents:minComponents];// 2023.5.1 00:00
            maxDate = [gregorian dateFromComponents:maxComponents]; // 2023.5.3 00:00
            NSTimeInterval time= [maxDate timeIntervalSinceDate:minDate];
            NSInteger dateNum = (time / 86400) + 1; // time/86400 = 2天，因为都算了零点。所以后面还要加上一天
            
            
            NSInteger numOfInvalidCell = 0;
            if ([MirrorSettings appliedWeekStarsOnMonday]) {
                if (minComponents.weekday > 1) {
                    numOfInvalidCell = minComponents.weekday - 2;
                } else {
                    numOfInvalidCell = 6;
                }
            } else {
                numOfInvalidCell = minComponents.weekday - 1;
            }
            _startTimestamp = [minDate timeIntervalSince1970] - numOfInvalidCell*86400; // 第一个cell(可能是invalid的)
            // 今天的0点
            NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate now]];
            components.timeZone = [NSTimeZone systemTimeZone];
            components.hour = 0;
            components.minute = 0;
            components.second = 0;
            long timestamp = [[gregorian dateFromComponents:components] timeIntervalSince1970];
            _selectedCellIndex = (timestamp-_startTimestamp)/86400;
            // 添加前面的空cell
            for (int i=0; i<numOfInvalidCell; i++) {
                NSInteger invalidDateTimestamp = [minDate timeIntervalSince1970] - (numOfInvalidCell-i)*86400;
                GridComponent *grid = [[GridComponent alloc] initWithValid:NO thatDayTasks:[NSMutableArray new]];
                [_data setValue:grid forKey:[@(invalidDateTimestamp) stringValue]];
            }
            // 添加valid cell
            for (int i=0; i<dateNum; i++) {
                NSInteger validDateTimestamp = [minDate timeIntervalSince1970] + i*86400;
                GridComponent *grid = [[GridComponent alloc] initWithValid:YES thatDayTasks:[MirrorDataManager getDataWithStart:validDateTimestamp end:validDateTimestamp+86400]];
                [_data setValue:grid forKey:[@(validDateTimestamp) stringValue]];
            }
        }
    }
    return _data;
}

#pragma mark - Privates

- (NSArray *)leftWidthLeftHeight
{
    CGFloat leftHeight = kScreenHeight - self.navigationController.navigationBar.frame.origin.y - self.navigationController.navigationBar.frame.size.height - (kCellWidth*7 + kCellSpacing*6) - 20 -20 -20 - [self.legendView legendViewHeight] - 10 - 20 - kTabBarHeight;
    CGFloat leftWidth = kScreenWidth - 2*kLeftRightSpacing;

    return @[@(leftWidth), @(leftHeight)];
}



@end
