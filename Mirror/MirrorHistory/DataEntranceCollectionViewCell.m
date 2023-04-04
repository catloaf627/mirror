//
//  DataEntranceCollectionViewCell.m
//  Mirror
//
//  Created by Yuqing Wang on 2023/4/4.
//

#import "DataEntranceCollectionViewCell.h"

@implementation DataEntranceCollectionViewCell

+ (NSString *)identifier;
{
    return NSStringFromClass(self.class);
}

- (void)configCellWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            self.contentView.backgroundColor = [UIColor systemPinkColor];
            break;
        case 1:
            self.contentView.backgroundColor = [UIColor systemPinkColor];
            break;
        case 2:
            self.contentView.backgroundColor = [UIColor systemPinkColor];
            break;
        case 3:
            self.contentView.backgroundColor = [UIColor systemPinkColor];
            break;
        default:
            break;
    }
    [self p_setupUI];
}

- (void)p_setupUI
{
    self.contentView.layer.cornerRadius = 14;
}

@end
