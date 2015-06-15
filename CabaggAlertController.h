//
//  CabaggAlertController.h
//  cabAgg
//
//  Created by Kanav Arora on 6/15/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CabaggAlertController : UIAlertController

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message;
- (void)show;

@end
