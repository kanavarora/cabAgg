//
//  DisplayResultsCollectionView.m
//  cabAgg
//
//  Created by Kanav Arora on 1/15/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "DisplayResultsCollectionView.h"

#import "ResultCollectionViewCell.h"
#import "ResultInfo.h"
#import "ResultsView.h"

@interface DisplayResultsCollectionView ()

@property (nonatomic, readwrite, strong) NSMutableArray *resultData;
@property (nonatomic, readwrite, assign) NSInteger selectedIndex;

@property (nonatomic, readwrite, strong) UICollectionViewFlowLayout *flowLayout;

@end

@implementation DisplayResultsCollectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self = [super initWithFrame:frame collectionViewLayout:flowLayout];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.bounces = NO;
        _flowLayout = flowLayout;
    }
    return self;
}

- (ResultInfo *)selectedResultInfo {
    if (self.selectedIndex > -1) {
        return self.resultData[self.selectedIndex];
    } else {
        return nil;
    }
}

- (void)setupResults {
    _resultData = [NSMutableArray array];
    ResultInfo *info1 = [[ResultInfo alloc] init];
    info1.cabType = CabTypeLyftLine;
    [_resultData addObject:info1];
    
    ResultInfo *info2 = [[ResultInfo alloc] init];
    info2.cabType = CabTypeLyft;
    [_resultData addObject:info2];
    
    ResultInfo *info3 = [[ResultInfo alloc] init];
    info3.cabType = CabTypeUberPool;
    [_resultData addObject:info3];
    
    ResultInfo *info4 = [[ResultInfo alloc] init];
    info4.cabType = CabTypeUberX;
    [_resultData addObject:info4];
    [self reloadData];

}

- (void)setupCollectionView {
    [self registerNib:[UINib nibWithNibName:@"ResultCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"resultCell"];
    
    [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.flowLayout setMinimumInteritemSpacing:0.0f];
    [self.flowLayout setMinimumLineSpacing:0.0f];
    self.showsHorizontalScrollIndicator = NO;
    //[self setPagingEnabled:YES];
    [self setCollectionViewLayout:self.flowLayout];
    self.delegate = self;
    self.dataSource = self;
    [self selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [self.resultsView didChangeSelectionOfResult];
}

- (void)updateResults {
    for (ResultInfo *info in self.resultData) {
        [info update];
    }
    NSArray * paths = [self indexPathsForVisibleItems];
    //  For getting the cells themselves
    NSMutableSet *visibleCells = [[NSMutableSet alloc] init];
    
    for (NSIndexPath *path in paths) {
        [visibleCells addObject:[self cellForItemAtIndexPath:path]];
    }
    
    for (ResultCollectionViewCell *visibleCell in visibleCells) {
        [visibleCell updateCost];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.row;
    ResultCollectionViewCell *cell = (ResultCollectionViewCell *)[self cellForItemAtIndexPath:indexPath];
    [cell selectCell];
    [self.resultsView didChangeSelectionOfResult];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    ResultCollectionViewCell *cell = (ResultCollectionViewCell *)[self cellForItemAtIndexPath:indexPath];
    [cell deselectCell];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.resultData.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ResultCollectionViewCell * cell = (ResultCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"resultCell" forIndexPath:indexPath];
    
    [cell setupWithResultInfo:self.resultData[indexPath.row]];
    if (indexPath.row == self.selectedIndex) {
        [cell selectCell];
    }
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float width = [UIScreen mainScreen].bounds.size.width/4.0f;
    width = MAX(90, width);
    return CGSizeMake(width, kHeightOfCell);
}


@end
