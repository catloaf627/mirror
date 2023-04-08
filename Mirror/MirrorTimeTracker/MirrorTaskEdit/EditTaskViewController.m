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
#import "MirrorStorage.h"

static CGFloat const kEditTaskVCPadding = 20;
static CGFloat const kHeightRatio = 0.8;

@interface EditTaskViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property (nonatomic, strong) MirrorDataModel *taskModel;
@property (nonatomic, strong) UITextField *editTaskNameTextField;
@property (nonatomic, strong) UILabel *editTaskNameHint;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<MirrorColorModel *> *colorBlocks;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, assign) MirrorColorType selectedColor;

@end

@implementation EditTaskViewController

- (instancetype)initWithTasks:(MirrorDataModel *)task
{
    self = [super init];
    if (self) {
        self.taskModel = task;
        self.editTaskNameTextField.text = _taskModel.taskName;
        self.selectedColor = _taskModel.color;
    }
    return self;
}

- (void)viewDidLayoutSubviews
{
    // 编辑task页面为半屏
    [self.view setFrame:CGRectMake(0, kScreenHeight*(1-kHeightRatio), kScreenWidth, kScreenHeight*kHeightRatio)];
    self.view.layer.cornerRadius = 20;
    self.view.layer.masksToBounds = YES;

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewGetsTapped:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.delegate = self;
    [self.view.superview addGestureRecognizer:tapRecognizer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p_setupUI];
}

- (void)p_setupUI
{
    self.view.backgroundColor = [UIColor mirrorColorNamed:self.taskModel.color];
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
    [self.view addSubview:self.deleteButton];
    [self.view addSubview:self.saveButton];
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.collectionView.mas_bottom).offset(20);
        make.left.offset(kEditTaskVCPadding);
        make.width.mas_equalTo(kScreenWidth/2-kEditTaskVCPadding);
        make.height.mas_equalTo(40);
    }];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.collectionView.mas_bottom).offset(20);
        make.left.mas_equalTo(self.deleteButton.mas_right).offset(0);
        make.width.mas_equalTo(kScreenWidth/2-kEditTaskVCPadding);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark - Actions

- (void)clickSaveButton
{
    NSString *currentText = self.editTaskNameTextField.text;
    BOOL textIsTheSame = [currentText isEqualToString:self.taskModel.taskName];
    BOOL textIsEmpty = !currentText || [currentText isEqualToString:@""];
    TaskNameExistsType existType = [MirrorStorage taskNameExists:currentText];
    if (textIsTheSame) { // taskname和之前一样，允许修改并退出
        [MirrorStorage editTask:self.taskModel.taskName color:self.selectedColor name:currentText];
        [self.delegate dismissViewControllerAnimated:YES completion:^{
            [self.delegate updateTasks];
        }];
    } else if (textIsEmpty) { // taskname为空，不允许修改
        UIAlertController* newNameIsEmptyAlert = [UIAlertController alertControllerWithTitle:[MirrorLanguage mirror_stringWithKey:@"name_field_cannot_be_empty"] message:nil preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* understandAction = [UIAlertAction actionWithTitle:[MirrorLanguage mirror_stringWithKey:@"gotcha"] style:UIAlertActionStyleDefault handler:nil];
        [newNameIsEmptyAlert addAction:understandAction];
        [self presentViewController:newNameIsEmptyAlert animated:YES completion:nil];
    } else if (existType != TaskNameExistsTypeValid) { // taskname重复了，不允许修改
        UIAlertController* newNameIsDuplicateAlert = [UIAlertController alertControllerWithTitle:[MirrorLanguage mirror_stringWithKey:@"task_cannot_be_duplicated"] message: [MirrorLanguage mirror_stringWithKey:existType == TaskNameExistsTypeExistsInCurrentTasks ? @"this_task_exists_in_current_task_list" : @"this_task_exists_in_the_archived_task_list"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* understandAction = [UIAlertAction actionWithTitle:[MirrorLanguage mirror_stringWithKey:@"gotcha"] style:UIAlertActionStyleDefault handler:nil];
        [newNameIsDuplicateAlert addAction:understandAction];
        [self presentViewController:newNameIsDuplicateAlert animated:YES completion:nil];
    } else { // taskname valid，允许修改并退出
        [MirrorStorage editTask:self.taskModel color:self.selectedColor name:currentText];
        [self.delegate dismissViewControllerAnimated:YES completion:^{
            [self.delegate updateTasks];
        }];
    }
}

- (void)clickDeleteButton
{
    UIAlertController* deleteButtonAlert = [UIAlertController alertControllerWithTitle:[MirrorLanguage mirror_stringWithKey:@"delete_task_?"] message:[MirrorLanguage mirror_stringWithKey:@"you_can_also_archive_this_task"] preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:[MirrorLanguage mirror_stringWithKey:@"delete"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate deleteTask:self.taskModel];
        }];
    }];
    
    UIAlertAction* archiveAction = [UIAlertAction actionWithTitle:[MirrorLanguage mirror_stringWithKey:@"archive"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate archiveTask:self.taskModel];
        }];
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:[MirrorLanguage mirror_stringWithKey:@"cancel"] style:UIAlertActionStyleDefault handler:nil];

    [deleteButtonAlert addAction:deleteAction];
    [deleteButtonAlert addAction:archiveAction];
    [deleteButtonAlert addAction:cancelAction];
    [self presentViewController:deleteButtonAlert animated:YES completion:nil];
}


#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 选中某色块时，更新背景颜色为该色块颜色，更新selectedColor为该色块颜色
    MirrorColorType selectedColor =  self.colorBlocks[indexPath.item].color;
    self.view.backgroundColor = [UIColor mirrorColorNamed:selectedColor];
    self.selectedColor = selectedColor;
    [collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return kMaxColorNum;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 展示所有色块
    MirrorColorModel *taskModel = (MirrorColorModel *)self.colorBlocks[indexPath.item];
    taskModel.isSelected = CGColorEqualToColor([UIColor mirrorColorNamed:taskModel.color].CGColor, [UIColor mirrorColorNamed:self.selectedColor].CGColor); // 如果某色块和当前选中的颜色一致，标记为选中
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

#pragma mark - Actions
// 给superview添加了点击手势（为了在点击上方不属于self.view的地方可以dismiss掉self）
- (void)viewGetsTapped:(UIGestureRecognizer *)tapRecognizer
{
    CGPoint touchPoint = [tapRecognizer locationInView:self.view];
    if (touchPoint.y <= 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIGestureRecognizerDelegate
// 这里需要判断下，如果点击的位置属于self.view，这时候忽略superview上的手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint touchPoint = [touch locationInView:self.view];
    if (touchPoint.y <= 0) {
        return YES;
    } else {
        return NO;
    }
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

- (UIButton *)deleteButton
{
    if (!_deleteButton) {
        _deleteButton = [UIButton new];
        // icon
        [_deleteButton setImage:[[UIImage systemImageNamed:@"xmark.rectangle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _deleteButton.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        // title
        [_deleteButton setTitle:[MirrorLanguage mirror_stringWithKey:@"delete"] forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor mirrorColorNamed:MirrorColorTypeText] forState:UIControlStateNormal];
        _deleteButton.titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:20];
        // padding
        _deleteButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
        // action
        [_deleteButton addTarget:self action:@selector(clickDeleteButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

- (UIButton *)saveButton
{
    if (!_saveButton) {
        _saveButton = [UIButton new];
        // icon
        [_saveButton setImage:[[UIImage systemImageNamed:@"checkmark.rectangle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _saveButton.tintColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        // title
        [_saveButton setTitle:[MirrorLanguage mirror_stringWithKey:@"save"] forState:UIControlStateNormal];
        [_saveButton setTitleColor:[UIColor mirrorColorNamed:MirrorColorTypeText] forState:UIControlStateNormal];
        _saveButton.titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:20];
        // padding
        _saveButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
        // action
        [_saveButton addTarget:self action:@selector(clickSaveButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

#pragma mark - Private methods

- (CGFloat)p_colorBlockWidth
{
    return (kScreenWidth - 2*kEditTaskVCPadding)/kMaxColorNum;
}

@end
