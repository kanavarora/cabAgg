//
//  ExtraViewController.m
//  cabAgg
//
//  Created by Kanav Arora on 3/2/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "ExtraViewController.h"

@interface ExtraViewController ()

@property (nonatomic, readwrite, weak) IBOutlet UIButton *adminButton;
@end

@implementation ExtraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.title = @"FAQ";
    if ([[[[UIDevice currentDevice] identifierForVendor] UUIDString] isEqualToString:@"AFC344C3-7DFF-4C1D-A69F-7066BA4A83D5"]) {
        self.adminButton.hidden = NO;
    }
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
                                 //[[UIApplication sharedApplication] setStatusBarHidden:NO];
                             }];
}

- (IBAction)tapAdminButton:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"hasOnboarded"];
}

@end
