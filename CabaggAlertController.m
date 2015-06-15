//
//  CabaggAlertController.m
//  cabAgg
//
//  Created by Kanav Arora on 6/15/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "CabaggAlertController.h"

#import "MainViewController.h"
#import "GlobalStateInterface.h"

@interface CabaggAlertController ()

@end

@implementation CabaggAlertController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message {
    CabaggAlertController *alertController = [CabaggAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             
                             
                         }];
    [alertController addAction:ok]; // add action to uialertcontroller
    return alertController;
}

- (void)show {
    [globalStateInterface.mainVC presentViewController:self animated:YES completion:nil];
}

@end
