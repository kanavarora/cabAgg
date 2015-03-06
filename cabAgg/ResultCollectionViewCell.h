//
//  ResultCollectionViewCell.h
//  cabAgg
//
//  Created by Kanav Arora on 1/15/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ResultInfo;
@interface ResultCollectionViewCell : UICollectionViewCell

- (void)setupWithResultInfo:(ResultInfo *)resultInfo;
- (void)updateCost;
- (void)selectCell;
- (void)deselectCell;

@end
