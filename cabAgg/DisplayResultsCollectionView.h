//
//  DisplayResultsCollectionView.h
//  cabAgg
//
//  Created by Kanav Arora on 1/15/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ResultInfo;
@class ResultsView;
#define kHeightOfCell 125
@interface DisplayResultsCollectionView : UICollectionView<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, readwrite, weak) ResultsView *resultsView;

- (ResultInfo *)selectedResultInfo;
- (void)setupCollectionView;
- (void)updateResults;

@end
