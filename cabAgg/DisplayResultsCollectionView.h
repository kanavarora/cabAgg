//
//  DisplayResultsCollectionView.h
//  cabAgg
//
//  Created by Kanav Arora on 1/15/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DisplayResultsCollectionView : UICollectionView<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

- (void)setupCollectionView;
- (void)updateResults;

@end
