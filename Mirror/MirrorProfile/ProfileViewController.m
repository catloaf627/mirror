//
//  ProfileViewController.m
//  Mirror
//
//  Created by Yuqing Wang on 2022/9/25.
//

#import "ProfileViewController.h"
#import "UIColor+MirrorColor.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor mirrorColorNamed:MirrorColorTypeBackground];
}


@end
