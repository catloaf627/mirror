//
//  ProfileViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/25.
//

#import "ProfileViewController.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>
#import "MirrorMacro.h"

#import "AvatarCollectionViewCell.h"
#import "ThemeCollectionViewCell.h"
#import "LanguageCollectionViewCell.h"

static CGFloat const kCellSpacing = 20; // cell之间的上下间距
static CGFloat const kCollectionViewPadding = 20; // 左右留白

typedef NS_ENUM(NSInteger, MirrorSettingType) {
    MirrorSettingTypeAvatar,
    MirrorSettingTypeTheme,
    MirrorSettingTypeLanguage,
};

@interface ProfileViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    [self  p_setupUI];
}

- (void)p_setupUI
{
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kCollectionViewPadding);
        make.right.mas_equalTo(self.view).offset(-kCollectionViewPadding);
        make.top.mas_equalTo(self.view).offset(kNavBarAndStatusBarHeight);
        make.bottom.mas_equalTo(self.view).offset(-kTabBarHeight);
    }];
}


# pragma mark - Collection view delegate

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item >= self.dataSource.count) {
        return [UICollectionViewCell new];
    } else if (indexPath.item == MirrorSettingTypeAvatar) {
        AvatarCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[AvatarCollectionViewCell identifier] forIndexPath:indexPath];
        [cell configCell];
        return cell;
    } else if (indexPath.item == MirrorSettingTypeTheme){
        ThemeCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[ThemeCollectionViewCell identifier] forIndexPath:indexPath];
        [cell configCell];
        return cell;
    } else if (indexPath.item == MirrorSettingTypeLanguage) {
        LanguageCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[LanguageCollectionViewCell identifier] forIndexPath:indexPath];
        [cell configCell];
        return cell;
    }
    
    return [UICollectionViewCell new];
   
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.item) {
        case MirrorSettingTypeAvatar:
            return CGSizeMake(kScreenWidth-2*kCollectionViewPadding, 140);
        case MirrorSettingTypeTheme:
            return CGSizeMake(kScreenWidth-2*kCollectionViewPadding, 80);
        case MirrorSettingTypeLanguage:
            return CGSizeMake(kScreenWidth-2*kCollectionViewPadding, 80);
        default:
            break;
    }
    return CGSizeMake(kScreenWidth, 80);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kCellSpacing;
}

#pragma mark - Getters
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = self.view.backgroundColor;
        [_collectionView registerClass:[AvatarCollectionViewCell class] forCellWithReuseIdentifier:[AvatarCollectionViewCell identifier]];
        [_collectionView registerClass:[ThemeCollectionViewCell class] forCellWithReuseIdentifier:[ThemeCollectionViewCell identifier]];
        [_collectionView registerClass:[LanguageCollectionViewCell class] forCellWithReuseIdentifier:[LanguageCollectionViewCell identifier]];
        
    }
    return _collectionView;
}

- (NSArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = @[@(MirrorSettingTypeAvatar), @(MirrorSettingTypeTheme), @(MirrorSettingTypeLanguage)];
    }
    return _dataSource;
}



@end
