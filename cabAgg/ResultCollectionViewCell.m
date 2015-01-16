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

@interface ResultCollectionViewCell ()

@property (nonatomic, readwrite, weak) IBOutlet PaddingLabel *titleLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *costLabel;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *bookButton;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *surgeLabel;
@property (nonatomic, readwrite, weak) IBOutlet UIImageView *surgeBg;
@property (nonatomic, readwrite, strong) ResultInfo *resultInfo;
@property (nonatomic, readwrite, assign) BOOL isSelected;

@end

@implementation ResultCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)clearData {
    self.surgeBg.hidden = YES;
    self.surgeLabel.hidden = YES;
}

- (void)setupWithResultInfo:(ResultInfo *)resultInfo {
    [self clearData];
    self.resultInfo = resultInfo;
    
    // set title
    self.titleLabel.backgroundColor = [ResultInfo backgroundColorForCabType:resultInfo.cabType];
    self.titleLabel.text = [ResultInfo titleForCabType:resultInfo.cabType];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.insets = UIEdgeInsetsMake(5, 0, 5, 0);
    
    
    // cost and surge
    [self updateCost];
    
    // button
    
    
}

- (IBAction)bookButtonTapped:(id)sender {
    NSString *urlSt = self.resultInfo.deepLinkUrl;
    if (!urlSt) {
        return;
    }
    NSURL *url = [NSURL URLWithString:urlSt];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    
}

- (void)updateCost {
    NSString *costText = @"";
    if (self.resultInfo.lowEstimate == self.resultInfo.highEstimate) {
        costText = [NSString stringWithFormat:@"%.2f", self.resultInfo.lowEstimate];
    } else {
        costText = [NSString stringWithFormat:@"%d-%d", (int)lroundf(self.resultInfo.lowEstimate), (int)lroundf(self.resultInfo.highEstimate)];
    }
    self.costLabel.text = costText;
    
    if (self.resultInfo.surgeMultiplier <= 1.0f) {
        self.surgeBg.hidden = YES;
        self.surgeLabel.hidden = YES;
    } else {
        self.surgeBg.hidden = NO;
        self.surgeLabel.hidden = NO;
        self.surgeLabel.text = [NSString stringWithFormat:@"%.1fx", self.resultInfo.surgeMultiplier];
    }
}



@end
