//
//  ToggleCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/10/24.
//

#import "ToggleCollectionViewCell.h"
#import <Masonry/Masonry.h>
#import "MirrorLanguage.h"

@interface ToggleCollectionViewCell ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation ToggleCollectionViewCell

- (void)configCellWithTitle:(NSString *)title color:(MirrorColorType)color
{
    self.contentView.backgroundColor = [UIColor mirrorColorNamed:color];
    self.contentView.layer.cornerRadius = 15;
    self.toggle.onTintColor = [UIColor mirrorColorNamed:[UIColor mirror_getPulseColorType:color]]; // toggle颜色使用pulse
    self.label.text = [MirrorLanguage mirror_stringWithKey:title];
    
    [self.contentView addSubview:self.toggle];
    [self.toggle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.right.offset(-30);
    }];
    [self.contentView addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.offset(30);
    }];
}

- (UILabel *)label
{
    if (!_label) {
        _label = [UILabel new];
        _label.textColor = [UIColor mirrorColorNamed:MirrorColorTypeText];
        _label.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:17];
    }
    return _label;
}

- (UISwitch *)toggle
{
    if (!_toggle) {
        _toggle = [UISwitch new];
    }
    return _toggle;
}


@end
