//
//  PaddingLabel.m
//  cabAgg
//
//  Created by Kanav Arora on 1/15/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "PaddingLabel.h"

@implementation PaddingLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) setInsets:(UIEdgeInsets)insets
{
    _insets = insets ;
    [self invalidateIntrinsicContentSize] ;
}

- (void)drawTextInRect:(CGRect)rect
{
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.insets)];
}

- (CGSize) intrinsicContentSize
{
    CGSize superSize = [super intrinsicContentSize] ;
    superSize.height += self.insets.top + self.insets.bottom ;
    superSize.width += self.insets.left + self.insets.right ;
    return superSize ;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end