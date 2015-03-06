//
//  ExtraViewController.m
//  cabAgg
//
//  Created by Kanav Arora on 3/2/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "ExtraViewController.h"

@interface ExtraViewController ()

@end

@implementation ExtraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [[UIApplication sharedApplication] setStatusBarHidden:NO];
                             }];
}

@end
