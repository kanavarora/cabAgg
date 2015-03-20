//
//  UIView+LoadingSpinner.m
//  stuph
//
//  Created by Kanav Arora on 11/18/14.
//  Copyright (c) 2014 Stuph Inc. All rights reserved.
//

#import "UIView+LoadingSpinner.h"
#import <objc/runtime.h>

@interface UIView ()

@end

static const void *ImageTagKey = &ImageTagKey;

@implementation UIView (LoadingSpinner)


- (void)setSpinner:(UIActivityIndicatorView *)spinner
{
    objc_setAssociatedObject(self, ImageTagKey, spinner, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)spinner
{
    return objc_getAssociatedObject(self, ImageTagKey);
}

- (void)showSpinner {
    if (self.spinner) {
        [self removeSpinner];
    }
    if (!self.spinner) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
        [self addSubview:spinner];
        self.spinner = spinner;
        [spinner startAnimating];
    }
}

- (void)showConstrainedSpinner {
    if (self.spinner) {
        [self removeSpinner];
    }
    if (!self.spinner) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        //spinner.center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
        spinner.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:spinner];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:spinner
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0f constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:spinner
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0f constant:0]];
        self.spinner = spinner;
        [spinner startAnimating];
    }
}

- (void)removeSpinner {
    [self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
    self.spinner = nil;
}


@end