//
//  LinechartView.m
//  Mirror
//
//  Created by Yuqing Wang on 2024/2/29.
//

#import "LinechartView.h"
#import <Masonry/Masonry.h>
#import "LineChartCollectionViewCell.h"
#import "MirrorDataModel.h"
#import "MirrorTool.h"

static CGFloat const kMinCellWidth = 14;

@interface LinechartView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) long maxtime;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary<NSString *, NSNumber *> *> *data;

@end

@implementation LinechartView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self p_setupUI];
    }
    return self;
}

- (void)p_setupUI
{
    self.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self).offset(0);
    }];
}

#pragma mark - UICollectionViewDataSource

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    LineChartCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[LineChartCollectionViewCell identifier] forIndexPath:indexPath];
    // onedaydata
    NSMutableDictionary<NSString *,NSNumber *> *onedaydata = self.data[indexPath.item];
    // leftdaydata
    NSMutableDictionary<NSString *,NSNumber *> *leftdaydata = nil;
    if (indexPath.item - 1 >= 0) leftdaydata = self.data[indexPath.item - 1];
    // rightdaydata
    NSMutableDictionary<NSString *,NSNumber *> *rightdaydata = nil;
    if (indexPath.item + 1 < [collectionView numberOfItemsInSection:0]) rightdaydata = self.data[indexPath.item + 1];
    
    [cell configCellWithOnedaydata:onedaydata leftdaydata:leftdaydata rightdaydata:rightdaydata maxtime:self.maxtime];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data.count;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width =  kMinCellWidth > self.bounds.size.width/self.data.count ? kMinCellWidth : self.bounds.size.width/self.data.count;
    return CGSizeMake(width, self.bounds.size.height);
}

#pragma mark - Refactor Data

- (void)refactorData:(NSMutableArray<NSMutableArray<MirrorDataModel *> *> *)originalData
{
    
    // update maxtime
    self.maxtime = 0;
    
    NSMutableArray *allTasknames = [NSMutableArray new];
    for (int i=0; i<originalData.count; i++) {
        NSMutableArray<MirrorDataModel *> *oneday = originalData[i];
        for (int j=0; j<oneday.count; j++) {
            MirrorDataModel *onedayonetask = oneday[j];
            long time = [MirrorTool getTotalTimeOfPeriods:onedayonetask.records];
            if (time > self.maxtime) self.maxtime = time; // 更新最久一次task的时间
            if (![allTasknames containsObject:onedayonetask.taskModel.taskName]) { // 更新所有task的名单
                [allTasknames addObject:onedayonetask.taskModel.taskName];
            }
        }
    }
    
    // update data
    self.data = [[NSMutableArray alloc] initWithCapacity:originalData.count];
    
    for (int i=0; i<originalData.count; i++) {
        NSMutableArray<MirrorDataModel *> *oneday = originalData[i];
        NSMutableDictionary<NSString *, NSNumber *> *onedayDict = [NSMutableDictionary new];
        for (int j=0; j<allTasknames.count; j++) {
            BOOL taskExisted = NO;
            NSMutableArray<MirrorRecordModel *> *periods = [@[] mutableCopy];
            for (int taskIndex=0; taskIndex<oneday.count; taskIndex++) {
                NSString *taskname0 = allTasknames[j];
                NSString *taskname1 = oneday[taskIndex].taskModel.taskName;
                if ([taskname0 isEqualToString:taskname1]) {
                    taskExisted = YES;
                    periods = oneday[taskIndex].records;
                    break;
                }
            }
            if (taskExisted) {
                NSString *key = allTasknames[j];
                NSNumber *value = @([MirrorTool getTotalTimeOfPeriods:periods]);
                [onedayDict setValue:value forKey:key];
            } else {
                NSString *key = allTasknames[j];
                NSNumber *value = @([MirrorTool getTotalTimeOfPeriods:periods]);
                [onedayDict setValue:value forKey:key];
            }
            
        }
        [self.data addObject:onedayDict];
    }
    [self.collectionView reloadData];
    /*
     原数据
   { [taskA:10h, taskB:20h]
     [taskC:19h]
     [taskA:47h, taskC:20h, taskD:48h]
     [taskB:84h, taskD:97h] }
     整理为
     alltasknames = [taskA, taskB, taskC, taskD]
     mastime = 97h
     输出为
     mastime = 97h
     data =
     { [taskA->10h,taskB->20h,taskC->0h, taskD->0h]
       [taskA->0h, taskB->0h, taskC->19h,taskD->0h]
       [taskA->47h,taskB->0h, taskC->20h,taskD->48h]
       [taskA->0h, taskB->84h,taskC->0h, taskD->97h] }
     */
}

#pragma mark - Getter

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
        [_collectionView registerClass:[LineChartCollectionViewCell class] forCellWithReuseIdentifier:[LineChartCollectionViewCell identifier]];
    }
    return _collectionView;
}

@end
