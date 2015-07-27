//
//  ResultCollectionViewCell.m
//  cabAgg
//
//  Created by Kanav Arora on 1/15/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "ResultCollectionViewCell.h"

#import "ResultInfo.h"
#import "PaddingLabel.h"
#import "GlobalStateInterface.h"

@interface ResultCollectionViewCell ()

@property (nonatomic, readwrite, weak) IBOutlet PaddingLabel *titleLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *costLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *saveTextLabel;
@property (nonatomic, readwrite, weak) IBOutlet UIActivityIndicatorView *spinnner;
@property (nonatomic, readwrite, weak) IBOutlet UIImageView *checkMarkView;
@property (nonatomic, readwrite, strong) ResultInfo *resultInfo;
@property (nonatomic, readwrite, assign) BOOL isSelected;

@end

@implementation ResultCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)clearData {
    self.saveTextLabel.hidden = YES;
    self.checkMarkView.hidden = YES;
    [self.spinnner stopAnimating];
    self.spinnner.hidden = YES;
}

- (void)setupWithResultInfo:(ResultInfo *)resultInfo {
    [self clearData];
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.layer.borderWidth = 1.0f;
    self.resultInfo = resultInfo;
    
    // set title
    self.backgroundColor = [ResultInfo backgroundColorForCabType:resultInfo.cabType];
    self.titleLabel.text = [ResultInfo titleForCabType:resultInfo.cabType];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.insets = UIEdgeInsetsMake(5, 0, 5, 0);
    
    // cost and surge
    [self updateCost];
    
}

- (void)updateCost {
    NSString *costText = @"";
    if (self.resultInfo.isRouteInvalid) {
        costText = @"NA";
    } else if (self.resultInfo.lowEstimate < 0 || self.resultInfo.lowEstimate > 1000) {
        costText = @"";
    } else if (self.resultInfo.lowEstimate == self.resultInfo.highEstimate) {
        costText = [NSString stringWithFormat:@"$%.2f", self.resultInfo.lowEstimate];
    } else {
        costText = [NSString stringWithFormat:@"$%d-%d", (int)lroundf(self.resultInfo.lowEstimate), (int)lroundf(self.resultInfo.highEstimate)];
    }
    self.costLabel.text = costText;
    float discount = self.resultInfo.actHighEstimate - self.resultInfo.highEstimate;
    
    if (discount <= 0 || (self.resultInfo.highEstimate < 0 || self.resultInfo.highEstimate > 1000)) {
        self.saveTextLabel.hidden = YES;
    } else {
        self.saveTextLabel.hidden = NO;
        self.saveTextLabel.text = [NSString stringWithFormat:@"You save: $%.2f", discount];
    }
    
    // spinner
    if ([self.resultInfo isDone]) {
        [self.spinnner stopAnimating];
        self.spinnner.hidden = YES;
    } else {
        if (!self.spinnner.isAnimating) {
            self.spinnner.hidden = NO;
            [self.spinnner startAnimating];
        }
    }
}

- (void)selectCell {
    self.backgroundColor = [ResultInfo backgroundColorForCabType:self.resultInfo.cabType];
    self.checkMarkView.hidden = NO;
}

- (void)deselectCell {
    self.backgroundColor = [ResultInfo backgroundColorForCabType:self.resultInfo.cabType];
    self.checkMarkView.hidden = YES;
}



@end
