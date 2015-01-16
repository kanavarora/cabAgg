//
//  DisplayView.h
//  cabAgg
//
//  Created by Kanav Arora on 1/4/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CabAggHttpClient;
@class ViewController;
@class MainViewController;

@interface DisplayView : UIView

@property (nonatomic, readwrite, strong) CabAggHttpClient *client;

- (id)initWithVC:(MainViewController *)vc;
- (void)updateResults;

@end
