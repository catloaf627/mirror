//
//  TimeTrackerViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/25.
//

#import "TimeTrackerViewController.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>
#import "TimeTrackerTaskCollectionViewCell.h"

@interface TimeTrackerViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation TimeTrackerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self  p_setupUI];
}

- (void)p_setupUI
{
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [collectionView registerClass:[TimeTrackerTaskCollectionViewCell class] forCellWithReuseIdentifier:@"TimeTrackerTaskCollectionViewCell"];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view).offset(kNavBarAndStatusBarHeight);
            make.bottom.mas_equalTo(self.view).offset(-kTabBarHeight);
    }];
    
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TimeTrackerTaskCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TimeTrackerTaskCollectionViewCell" forIndexPath:indexPath];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 300;
}


@end
