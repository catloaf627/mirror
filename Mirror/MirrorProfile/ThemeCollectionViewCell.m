//
//  ThemeCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/28.
//

#import "ThemeCollectionViewCell.h"
#import "UIColor+MirrorColor.h"
#import <Masonry/Masonry.h>
#import "MirrorLanguage.h"


@interface ThemeCollectionViewCell ()

@property (nonatomic, strong) UILabel *applyDarkModeLabel;
@property (nonatomic, strong) UISwitch *themeToggle;

@end

@implementation ThemeCollectionViewCell

+ (NSString *)identifier
{
    return NSStringFromClass(self.class);
}

- (void)configCell
{
    [self p_setupUI];
}

- (void)p_setupUI
{
    self.contentView.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeCellPink];
    self.contentView.layer.cornerRadius = 15;
    [self.contentView addSubview:self.themeToggle];
    [self.themeToggle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.right.offset(-30);
    }];
    [self.contentView addSubview:self.applyDarkModeLabel];
    [self.applyDarkModeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.offset(30);
    }];
}

- (UILabel *)applyDarkModeLabel
{
    if (!_applyDarkModeLabel) {
        _applyDarkModeLabel = [UILabel new];
        _applyDarkModeLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        _applyDarkModeLabel.text = [MirrorLanguage mirror_stringWithKey:@"apply_darkmode"];
        _applyDarkModeLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:17];
    }
    return _applyDarkModeLabel;
}

- (UISwitch *)themeToggle
{
    if (!_themeToggle) {
        _themeToggle = [UISwitch new];
        _themeToggle.onTintColor = [UIColor mirrorColorNamed:MirrorColorTypeCellPinkPulse];
        [_themeToggle addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        if ([UIColor isDarkMode]) {
            [_themeToggle setOn:YES animated:YES];
        } else {
            [_themeToggle setOn:NO animated:YES];
        }
    }
    return _themeToggle;
}

- (void)switchChanged:(UISwitch *)sender {
   // Do something
    [UIColor switchTheme];
}
    

@end
