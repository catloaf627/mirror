//
//  LinechartView.m
//  Mirror
//
//  Created by Yuqing Wang on 2024/2/29.
//

#import "LinechartView.h"
#import <Masonry/Masonry.h>

@interface LinechartView () /*<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>*/

@property (nonatomic, strong) NSMutableArray<NSMutableArray<MirrorDataModel *> *> *dataSource;
//@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation LinechartView

- (instancetype)initWithDataArr:(NSMutableArray<NSMutableArray<MirrorDataModel *> *> *)dataArr
{
    self = [super init];
    if (self) {
        self.dataSource = dataArr;
        [self p_setupUI];
    }
    return self;
}

- (LinechartView *)updateLineChart:(LinechartView *)oldLinechart withDataArr:(NSMutableArray<NSMutableArray<MirrorDataModel *> *> *)dataArr
{
    return oldLinechart;
}

- (void)p_setupUI
{
    self.backgroundColor = [UIColor systemPinkColor];
//    [self addSubview:self.collectionView];
//    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.bottom.mas_equalTo(self).offset(0);
//    }];
}

//#pragma mark - UICollectionViewDataSource
//
//- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    return [UICollectionViewCell new];
//}
//
//- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return self.dataSource.count;
//}
//
//#pragma mark - Getter
//
//- (UICollectionView *)collectionView
//{
//    if (!_collectionView) {
//        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
//        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
//        _collectionView.delegate = self;
//        _collectionView.dataSource = self;
////        layout.minimumLineSpacing = kCellSpacing;
//        _collectionView.backgroundColor = [UIColor systemPinkColor];
////        [_collectionView registerClass:[LanguageCollectionViewCell class] forCellWithReuseIdentifier:[LanguageCollectionViewCell identifier]];
//    }
//    return _collectionView;
//}

@end
