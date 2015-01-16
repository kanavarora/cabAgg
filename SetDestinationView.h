//
//  SetDestinationView.h
//  cabAgg
//
//  Created by Kanav Arora on 1/14/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DestinationViewStateEmpty = 0,
    DestinationViewStatePin,
    DestinationViewStateAddress,
} DestinationViewState;

@class MainViewController;
@interface SetDestinationView : UIView

- (void)setupIsPickup:(BOOL)isPickup
             parentVC:(MainViewController *)mainVC;
- (void)setWithAddress:(NSString *)address;
- (void)setWithPin;

@end
