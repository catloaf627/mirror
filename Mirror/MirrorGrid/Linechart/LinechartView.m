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

static CGFloat const kMinCellWidth = 14; // histogram cell左右的距离

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
    self.backgroundColor = [UIColor systemPinkColor];
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
    CGFloat width =  kMinCellWidth > self.bounds.size.width/self.data.count - 1 ? kMinCellWidth : self.bounds.size.width/self.data.count - 1; // gizmo 最后把-1删掉
    return CGSizeMake(width, self.bounds.size.height);
}

#pragma mark - Refactor Data

- (void)refactorData:(NSMutableArray<NSMutableArray<MirrorDataModel *> *> *)originalData
{
    
    // update maxtime
    self.maxtime = 0;
    
    NSMutableArray *allTaskModels = [NSMutableArray new];
    for (int i=0; i<originalData.count; i++) {
        NSMutableArray<MirrorDataModel *> *oneday = originalData[i];
        for (int j=0; j<oneday.count; j++) {
            MirrorDataModel *onedayonetask = oneday[j];
            long time = [MirrorTool getTotalTimeOfPeriods:onedayonetask.records];
            if (time > self.maxtime) self.maxtime = time; // 更新最久一次task的时间
            if (![allTaskModels containsObject:onedayonetask.taskModel.taskName]) { // 更新所有task的名单
                [allTaskModels addObject:onedayonetask.taskModel.taskName];
            }
        }
    }
    
    // update data
    self.data = [[NSMutableArray alloc] initWithCapacity:originalData.count];
    
    for (int i=0; i<originalData.count; i++) {
        NSMutableArray<MirrorDataModel *> *oneday = originalData[i];
        NSMutableDictionary<NSString *, NSNumber *> *onedayDict = [NSMutableDictionary new];
        for (int j=0; j<oneday.count; j++) {
            MirrorDataModel *onedayonetask = oneday[j];
            if ([allTaskModels containsObject:onedayonetask.taskModel.taskName]) { // 原数据里就有这个task
                // 将这个task存进self.data
                NSString *key = onedayonetask.taskModel.taskName;
                NSNumber *value = @([MirrorTool getTotalTimeOfPeriods:onedayonetask.records]);
                [onedayDict setValue:value forKey:key];
            } else { // 原数据里没有这个task
                // 将这个空records存进self.data
                NSString *key = onedayonetask.taskModel.taskName;
                NSNumber *value = @([MirrorTool getTotalTimeOfPeriods:[@[] mutableCopy]]);
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
        layout.minimumLineSpacing = 1;
        layout.minimumInteritemSpacing = 1; //gizmo 最后改成0
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor systemPinkColor];
        [_collectionView registerClass:[LineChartCollectionViewCell class] forCellWithReuseIdentifier:[LineChartCollectionViewCell identifier]];
    }
    return _collectionView;
}

@end
