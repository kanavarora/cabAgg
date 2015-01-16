//
//  LocationSearchTableViewCell.m
//  cabAgg
//
//  Created by Kanav Arora on 1/14/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "LocationSearchTableViewCell.h"

#import "LocationSearchViewController.h"

@interface LocationSearchTableViewCell ()

@property (nonatomic, readwrite, strong) IBOutlet UILabel *address;

@property (nonatomic, readwrite, strong) NSDictionary *addressDict;
@property (nonatomic, readwrite, weak) UITapGestureRecognizer *tapRecog;
@property (nonatomic, readwrite, weak) LocationSearchViewController *parentVC;

@end

@implementation LocationSearchTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.address.preferredMaxLayoutWidth = CGRectGetWidth(self.address.frame);
}

- (void)clearData {
    self.address.text = @"";
}

- (void)setupWithAddress:(NSDictionary *)addressDict
                parentVC:(LocationSearchViewController *)parentVC {
    [self clearData];
    self.parentVC = parentVC;
    self.addressDict = addressDict;
    self.address.text = addressDict[@"formattedAddress"];
    if (!self.tapRecog) {
        UITapGestureRecognizer *tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped)];
        [self addGestureRecognizer:tapRecog];
        self.tapRecog = tapRecog;
    }
}

- (void)cellTapped {
    [self.parentVC locationSelectedWith:self.addressDict];
}

@end
