//
//  LanguageCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/28.
//

#import "LanguageCollectionViewCell.h"
#import "UIColor+MirrorColor.h"

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
    self.contentView.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeCellOrange];
    self.contentView.layer.cornerRadius = 15;
}

@end
