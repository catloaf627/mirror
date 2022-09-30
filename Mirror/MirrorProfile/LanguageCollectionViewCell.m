//
//  LanguageCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/28.
//

#import "LanguageCollectionViewCell.h"
#import "UIColor+MirrorColor.h"

#import <Masonry/Masonry.h>
#import "MirrorLanguage.h"

static MirrorColorType const languageColorType = MirrorColorTypeCellOrange;

@interface LanguageCollectionViewCell ()

@property (nonatomic, strong) UILabel *applyChineseLabel;
@property (nonatomic, strong) UISwitch *languageToggle;

@end

@implementation LanguageCollectionViewCell

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
    self.contentView.backgroundColor = [UIColor mirrorColorNamed:languageColorType];
    self.contentView.layer.cornerRadius = 15;
    [self.contentView addSubview:self.languageToggle];
    [self.languageToggle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.right.offset(-30);
    }];
    [self.contentView addSubview:self.applyChineseLabel];
    [self.applyChineseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.offset(30);
    }];
}

- (UILabel *)applyChineseLabel
{
    if (!_applyChineseLabel) {
        _applyChineseLabel = [UILabel new];
        _applyChineseLabel.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        _applyChineseLabel.text = [MirrorLanguage mirror_stringWithKey:@"apply_chinese"];
        _applyChineseLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:17];
    }
    return _applyChineseLabel;
}

- (UISwitch *)languageToggle
{
    if (!_languageToggle) {
        _languageToggle = [UISwitch new];
        _languageToggle.onTintColor = [UIColor mirrorColorNamed:[UIColor mirror_getPulseColorType:languageColorType]];  // toggle颜色使用pulse
        [_languageToggle addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        if ([MirrorLanguage isChinese]) {
            [_languageToggle setOn:YES animated:YES];
        } else {
            [_languageToggle setOn:NO animated:YES];
        }
    }
    return _languageToggle;
}

- (void)switchChanged:(UISwitch *)sender {
   // Do something
    [MirrorLanguage switchLanguage];
}

@end
