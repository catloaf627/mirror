//
//  SettingsViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/25.
//

#import "SettingsViewController.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>
#import "MirrorMacro.h"

#import "AvatarCollectionViewCell.h"
#import "ThemeCollectionViewCell.h"
#import "LanguageCollectionViewCell.h"
#import "WeekStartsOnCollectionViewCell.h"
#import "ShowIndexCollectionViewCell.h"
#import "ExportDataCollectionViewCell.h"
#import "MirrorTabsManager.h"
#import "MirrorLanguage.h"
#import "LeftAnimation.h"

static CGFloat const kCellSpacing = 20; // cell之间的上下间距
static CGFloat const kCollectionViewPadding = 20; // 左右留白

typedef NS_ENUM(NSInteger, MirrorSettingType) {
    MirrorSettingTypeAvatar,
    MirrorSettingTypeTheme,
    MirrorSettingTypeLanguage,
    MirrorSettingTypeWeekStartsOn,
    MirrorSettingTypeShowIndex,
    MirrorSettingTypeExport,
};

@interface SettingsViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;

@end

@implementation SettingsViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartVC) name:MirrorSwitchThemeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartVC) name:MirrorSwitchLanguageNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)restartVC
{
    // 将vc.view里的所有subviews全部置为nil
    self.collectionView = nil;
    // 将vc.view里的所有subviews从父view上移除
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self  p_setupUI];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self  p_setupUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    // 手势(点击外部dismiss)
    [super viewDidAppear:animated];
    UITapGestureRecognizer *tapRecognizer = [UITapGestureRecognizer new];
    tapRecognizer.delegate = self;
    [self.view.superview addGestureRecognizer:tapRecognizer];
    // 手势(滑动内部dismiss)
    UIPanGestureRecognizer *panRecognizer = [UIPanGestureRecognizer new];
    [panRecognizer addTarget:self action:@selector(panGestureRecognizerAction:)];
    [self.view addGestureRecognizer:panRecognizer];
    
    // 动画
    self.transitioningDelegate = self;
}

- (void)p_setupUI
{
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeAddTaskCellBG];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(kCollectionViewPadding);
        make.right.mas_equalTo(self.view).offset(-kCollectionViewPadding);
        make.top.mas_equalTo(self.view).offset(self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);
        make.bottom.mas_equalTo(self.view);
    }];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:UITapGestureRecognizer.class]) {
        CGPoint touchPoint = [touch locationInView:self.view];
        if (touchPoint.x <= self.view.frame.size.width) {
            // 点了view里面
        } else {
            [self dismiss];// 点了view外面
        }
    }
    if ([gestureRecognizer isKindOfClass:UIPanGestureRecognizer.class]) {
        return YES;
    }
    return NO;
}

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)pan
{
    //产生百分比
    CGFloat process = -[pan translationInView:self.view].x / (self.view.frame.size.width);
    
    process = MIN(1.0,(MAX(0.0, process)));
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.interactiveTransition = [UIPercentDrivenInteractiveTransition new];
        //触发dismiss转场动画
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if (pan.state == UIGestureRecognizerStateChanged){
        [self.interactiveTransition updateInteractiveTransition:process];
    }else if (pan.state == UIGestureRecognizerStateEnded
              || pan.state == UIGestureRecognizerStateCancelled){
        if (process > 0.5) {
            [ self.interactiveTransition finishInteractiveTransition];
        }else{
            [ self.interactiveTransition cancelInteractiveTransition];
        }
        self.interactiveTransition = nil;
    }
}


# pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item >= self.dataSource.count) {
        return;
    } else if (indexPath.item == MirrorSettingTypeAvatar) {
        // glick avatar cell
    } else if (indexPath.item == MirrorSettingTypeTheme) {
        // Do nothing (use toggle to switch theme)
    } else if (indexPath.item == MirrorSettingTypeLanguage) {
        // Do nothing (use toggle to switch language)
    } else if (indexPath.item == MirrorSettingTypeWeekStartsOn) {
        // Do nothing (use toggle to switch weekStartsOn)
    } else if (indexPath.item == MirrorSettingTypeExport) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        NSData *tasksData = [NSData dataWithContentsOfFile:[path stringByAppendingPathComponent:@"tasks.mirror"] options:0 error:nil];
        NSData *recordsData = [NSData dataWithContentsOfFile:[path stringByAppendingPathComponent:@"records.mirror"] options:0 error:nil];
        NSArray *activityItems = @[tasksData ?: [NSData new], recordsData ?: [NSData new]];
        UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        activityViewControntroller.excludedActivityTypes = @[];
        activityViewControntroller.popoverPresentationController.sourceView = self.view;
        activityViewControntroller.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/4, 0, 0);
        [self presentViewController:activityViewControntroller animated:true completion:nil];
    }
}

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
    } else if (indexPath.item == MirrorSettingTypeWeekStartsOn) {
        WeekStartsOnCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[WeekStartsOnCollectionViewCell identifier] forIndexPath:indexPath];
        [cell configCell];
        return cell;
    } else if (indexPath.item == MirrorSettingTypeShowIndex) {
        ShowIndexCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[ShowIndexCollectionViewCell identifier] forIndexPath:indexPath];
        [cell configCell];
        return cell;
    } else if (indexPath.item == MirrorSettingTypeExport) {
        ExportDataCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[ExportDataCollectionViewCell identifier] forIndexPath:indexPath];
        [cell configCell];
        return cell;
    }
    
    return [UICollectionViewCell new];
   
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.item) {
        case MirrorSettingTypeAvatar:
            return CGSizeMake(collectionView.frame.size.width, 140*kLeftSheetRatio);
        default:
            return CGSizeMake(collectionView.frame.size.width, 52*kLeftSheetRatio);
    }
    return CGSizeMake(collectionView.frame.size.width, 0);
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
        [_collectionView registerClass:[WeekStartsOnCollectionViewCell class] forCellWithReuseIdentifier:[WeekStartsOnCollectionViewCell identifier]];
        [_collectionView registerClass:[ShowIndexCollectionViewCell class] forCellWithReuseIdentifier:[ShowIndexCollectionViewCell identifier]];
        [_collectionView registerClass:[ExportDataCollectionViewCell class] forCellWithReuseIdentifier:[ExportDataCollectionViewCell identifier]];
    }
    return _collectionView;
}

- (NSArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = @[@(MirrorSettingTypeAvatar), @(MirrorSettingTypeTheme), @(MirrorSettingTypeLanguage), @(MirrorSettingTypeWeekStartsOn), @(MirrorSettingTypeShowIndex), @(MirrorSettingTypeExport)];
    }
    return _dataSource;
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    LeftAnimation *animation = [LeftAnimation new];
    animation.isPresent = NO;
    return animation;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return self.interactiveTransition;
}


@end
