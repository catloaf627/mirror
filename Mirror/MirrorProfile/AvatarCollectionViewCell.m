//
//  AvatarCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/28.
//

#import "AvatarCollectionViewCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+MirrorColor.h"
#import "MirrorLanguage.h"

static CGFloat const kAvatarWidth = 96;

@interface AvatarCollectionViewCell ()

@property (nonatomic, strong) UIImageView *avatarImage;
@property (nonatomic, strong) UIView *avatar;
@property (nonatomic, strong) UILabel *nickname;

@end

@implementation AvatarCollectionViewCell

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
    [self.contentView addSubview:self.avatar];
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.offset(8);
        make.width.height.mas_equalTo(kAvatarWidth);
    }];
    [self.avatar addSubview:self.avatarImage];
    [self.avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.offset(0);
        make.width.height.mas_equalTo(60);
    }];
    [self.contentView addSubview:self.nickname];
    [self.nickname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.mas_equalTo(self.avatar.mas_bottom).offset(8);
    }];
}

#pragma mark - Getters

- (UIImageView *)avatarImage
{
    if (!_avatarImage) {
        UIImage *image = [[UIImage systemImageNamed:@"person.fill"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _avatarImage = [[UIImageView alloc]initWithImage:image];
        [_avatarImage setTintColor:[UIColor mirrorColorNamed:MirrorColorTypeCellGrayPulse]];
    }
    return _avatarImage;
}

- (UIView *)avatar
{
    if (!_avatar) {
        _avatar = [UIView new];
        _avatar.layer.cornerRadius = kAvatarWidth/2;
        _avatar.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeCellGray];
        
    }
    return _avatar;
}

-(UILabel *)nickname
{
    if (!_nickname) {
        _nickname = [UILabel new];
        _nickname.text = [MirrorLanguage stringWithKey:@"nickname" Language:MirrorLanguageTypeEnglish];
        _nickname.textColor = [UIColor mirrorColorNamed:MirrorColorTypeCellGrayPulse];
        _nickname.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:17];
    }
    return _nickname;
}

@end
