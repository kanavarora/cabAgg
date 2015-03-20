//
//  UIView+LoadingSpinner.h
//  stuph
//
//  Created by Kanav Arora on 11/18/14.
//  Copyright (c) 2014 Stuph Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LoadingSpinner)

@property (nonatomic, readwrite, strong) UIActivityIndicatorView *spinner;

- (void)showSpinner;
- (void)showConstrainedSpinner;
- (void)removeSpinner;

@end