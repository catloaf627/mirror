//
//  EditTaskViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/29.
//

#import "EditTaskViewController.h"
#import "MirrorMacro.h"
#import <Masonry/Masonry.h>
#import "UIColor+MirrorColor.h"
#import "MirrorLanguage.h"
#import "ColorCollectionViewCell.h"

static CGFloat const kEditTaskVCPadding = 20;

@interface EditTaskViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) TimeTrackerTaskModel *taskModel;
@property (nonatomic, assign) MirrorColorType taskColor;
@property (nonatomic, strong) UITextField *editTaskNameTextField;
@property (nonatomic, strong) UILabel *editTaskNameHint;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<MirrorColorModel *> *colorBlocks;

@end

@implementation EditTaskViewController

- (instancetype)initWithTasks:(TimeTrackerTaskModel *)task
{
    self = [super init];
    if (self) {
        self.taskModel = task;
        self.taskColor = _taskModel.color;
        self.editTaskNameTextField.text = _taskModel.taskName;
    }
    return self;
}

- (void)viewDidLayoutSubviews
{
    // 编辑task页面为半屏
    [self.view setFrame:CGRectMake(0, kScreenHeight/5*1, kScreenWidth, kScreenHeight/5*4)];
    self.view.layer.cornerRadius = 20;
    self.view.layer.masksToBounds = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_setupUI];
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.taskModel.taskName = self.editTaskNameTextField.text; // 保存taskname
    self.taskModel.color = self.taskColor; // 保存color
    [self.delegate updateTasks];
}

- (void)p_setupUI
{
    self.view.backgroundColor = [UIColor mirrorColorNamed:_taskColor];
    [self.view addSubview:self.editTaskNameTextField];
    [self.editTaskNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(20);
        make.centerX.offset(0);
        make.width.mas_equalTo(kScreenWidth - 2*kEditTaskVCPadding);
    }];
    [self.view addSubview:self.editTaskNameHint];
    [self.editTaskNameHint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.editTaskNameTextField.mas_bottom).offset(8);
        make.centerX.offset(0);
        make.width.mas_equalTo(kScreenWidth - 2*kEditTaskVCPadding);
    }];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.editTaskNameHint.mas_bottom).offset(16);
        make.centerX.offset(0);
        make.width.mas_equalTo(kScreenWidth - 2*kEditTaskVCPadding);
        make.height.mas_equalTo([self p_colorBlockWidth]);
    }];
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 选中某色块时，更新背景颜色为该色块颜色，更新model的颜色为该色块颜色
    MirrorColorType *selectedColor =  self.colorBlocks[indexPath.item].color;
    self.view.backgroundColor = [UIColor mirrorColorNamed:selectedColor];
    self.taskColor = selectedColor;
    [collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return kMaxTaskNum;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 展示所有色块
    MirrorColorModel *taskModel = (MirrorColorModel *)self.colorBlocks[indexPath.item];
    taskModel.isSelected = CGColorEqualToColor([UIColor mirrorColorNamed:taskModel.color].CGColor, [UIColor mirrorColorNamed:self.taskColor].CGColor); // 如果某色块和当前model的颜色一致，标记为选中
    ColorCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:[ColorCollectionViewCell identifier] forIndexPath:indexPath];
    // 更新色块（颜色、是否选中）
    [cell configWithModel:taskModel];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = [self p_colorBlockWidth];
    return CGSizeMake(width, width);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark - Getters

- (UITextField *)editTaskNameTextField
{
    if (!_editTaskNameTextField) {
        _editTaskNameTextField = [UITextField new];
        _editTaskNameTextField.text = self.taskModel.taskName;
        _editTaskNameTextField.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        _editTaskNameTextField.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:20];
        _editTaskNameTextField.enabled = YES;
        _editTaskNameTextField.textAlignment = NSTextAlignmentCenter;
    }
    return _editTaskNameTextField;
}

- (UILabel *)editTaskNameHint
{
    if (!_editTaskNameHint) {
        _editTaskNameHint = [UILabel new];
        _editTaskNameHint.text = [MirrorLanguage mirror_stringWithKey:@"edit_taskname_hint"];
        _editTaskNameHint.textColor = [UIColor mirrorColorNamed:MirrorColorTypeTextHint];
        _editTaskNameHint.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:12];
        _editTaskNameHint.textAlignment = NSTextAlignmentCenter;
        
    }
    return _editTaskNameHint;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        
        [_collectionView registerClass:[ColorCollectionViewCell class] forCellWithReuseIdentifier:[ColorCollectionViewCell identifier]];
    }
    return _collectionView;
}

- (NSArray<MirrorColorModel *> *)colorBlocks
{
    MirrorColorModel *pinkModel = [MirrorColorModel new];
    pinkModel.color = MirrorColorTypeCellPink;
    MirrorColorModel *orangeModel = [MirrorColorModel new];
    orangeModel.color = MirrorColorTypeCellOrange;
    MirrorColorModel *yellowModel = [MirrorColorModel new];
    yellowModel.color = MirrorColorTypeCellYellow;
    MirrorColorModel *greenModel = [MirrorColorModel new];
    greenModel.color = MirrorColorTypeCellGreen;
    MirrorColorModel *tealModel = [MirrorColorModel new];
    tealModel.color = MirrorColorTypeCellTeal;
    MirrorColorModel *blueModel = [MirrorColorModel new];
    blueModel.color = MirrorColorTypeCellBlue;
    MirrorColorModel *purpleModel = [MirrorColorModel new];
    purpleModel.color = MirrorColorTypeCellPurple;
    MirrorColorModel *grayModel = [MirrorColorModel new];
    grayModel.color = MirrorColorTypeCellGray;
    return @[pinkModel,orangeModel,yellowModel,greenModel,tealModel,blueModel,purpleModel,grayModel];
}

#pragma mark - Private methods
- (CGFloat)p_colorBlockWidth
{
    return (kScreenWidth - 2*kEditTaskVCPadding)/kMaxTaskNum;
}

@end
