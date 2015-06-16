//
//  UIView+Border.h
//  cabAgg
//
//  Created by Kanav Arora on 6/16/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Border)

+ (void)constraintView:(UIView *)childView
           toSuperView:(UIView *)superView
                insets:(UIEdgeInsets)insets;

- (void)addBottomBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;

- (void)addLeftBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;

- (void)addRightBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;

- (void)addTopBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;

- (void)addConstainedTopBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth;

- (void)addConstainedBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth;

- (void)addRoundedCorners:(float)cornerWidth;

- (void)addShadowWithColor:(UIColor *)color
                   opacity:(float)opacity
                    offset:(CGSize)offset
                      blur:(float)blur
              cornerRadius:(float)cornerRadius;
- (void)addBottomShadowWithColor:(UIColor *)color
                         opacity:(float)opacity
                          offset:(CGSize)offset
                            blur:(float)blur
                    cornerRadius:(float)cornerRadius;

- (void)addTopRoundedCorners:(float)cornerWidth;
- (void)addLeftRoundedCorners:(float)cornerWidth;
- (void)addBottomRoundedCorners:(float)cornerWidth;
@end
