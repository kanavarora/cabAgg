//
//  ResultsView.h
//  cabAgg
//
//  Created by Kanav Arora on 2/16/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ResultInfo;

#define kHeightOfBookButton 52
#define kWidthofBookButton 210
@interface ResultsView : UIView

- (void)didChangeSelectionOfResult;
- (void)setupCollectionView;
- (ResultInfo *)selectedResultInfo;
- (void)updateResults;
- (void)startCalculatingResults;

@end
