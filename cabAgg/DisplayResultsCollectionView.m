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

@interface DisplayResultsCollectionView ()

@property (nonatomic, readwrite, strong) NSMutableArray *resultData;

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
        _flowLayout = flowLayout;
    }
    return self;
}

- (void)setupResults {
    _resultData = [NSMutableArray array];
    ResultInfo *info1 = [[ResultInfo alloc] init];
    info1.cabType = CabTypeLyftLineWalk;
    [_resultData addObject:info1];
    
    ResultInfo *info2 = [[ResultInfo alloc] init];
    info2.cabType = CabTypeLyftLineActual;
    [_resultData addObject:info2];
    
    ResultInfo *info3 = [[ResultInfo alloc] init];
    info3.cabType = CabTypeUberPoolWalk;
    [_resultData addObject:info3];
    
    ResultInfo *info4 = [[ResultInfo alloc] init];
    info4.cabType = CabTypeUberPoolActual;
    [_resultData addObject:info4];
    
    ResultInfo *info5 = [[ResultInfo alloc] init];
    info5.cabType = CabTypeUberWalk;
    [_resultData addObject:info5];
    
    ResultInfo *info6 = [[ResultInfo alloc] init];
    info6.cabType = CabTypeUberActual;
    [_resultData addObject:info6];
}

- (void)setupCollectionView {
    [self registerNib:[UINib nibWithNibName:@"ResultCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"resultCell"];
    
    [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.flowLayout setMinimumInteritemSpacing:0.0f];
    [self.flowLayout setMinimumLineSpacing:0.0f];
    //[self setPagingEnabled:YES];
    [self setCollectionViewLayout:self.flowLayout];
    self.delegate = self;
    self.dataSource = self;
    [self setupResults];
    [self reloadData];
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

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.resultData.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ResultCollectionViewCell * cell = (ResultCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"resultCell" forIndexPath:indexPath];
    
    [cell setupWithResultInfo:self.resultData[indexPath.row]];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(150, 200);
}


@end
