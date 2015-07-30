//
//  ModifiedHitAreaButton.m
//  stuph
//
//  Created by Kanav Arora on 4/29/15.
//  Copyright (c) 2015 Stuph Inc. All rights reserved.
//

#import "ModifiedHitAreaButton.h"

@implementation ModifiedHitAreaButton

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGSizeEqualToSize(self.hitAreaSize, CGSizeZero) ) {
        return [super hitTest:point withEvent:event];
    }
    
    if (!self.isUserInteractionEnabled || self.isHidden || !self.enabled) {
        return nil;
    }
    CGSize currentSize = self.frame.size;
    float horizontalHitTestPadding = currentSize.width > 0 ? (-(self.hitAreaSize.width - currentSize.width)/2.0f) : 0;
    float verticalHitTestPadding = currentSize.height > 0 ? (-(self.hitAreaSize.height - currentSize.width)/2.0f) : 0;
    CGRect touchRect = CGRectInset(self.bounds, horizontalHitTestPadding, verticalHitTestPadding);
    if (CGRectContainsPoint(touchRect, point)) {
        for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
            CGPoint convertedPoint = [subview convertPoint:point fromView:self];
            UIView *hitTestView = [subview hitTest:convertedPoint withEvent:event];
            if (hitTestView) {
                return hitTestView;
            }
        }
        return self;
    }
    return nil;
}

@end