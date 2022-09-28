//
//  ThemeCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/28.
//

#import "ThemeCollectionViewCell.h"
#import "UIColor+MirrorColor.h"

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
}
    

@end
