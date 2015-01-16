//
//  SetDestinationView.m
//  cabAgg
//
//  Created by Kanav Arora on 1/14/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "SetDestinationView.h"

#import "LocationSearchViewController.h"
#import "MainViewController.h"

@interface SetDestinationView ()

@property (nonatomic, readwrite, assign) BOOL isPickup;
@property (nonatomic, readwrite, weak) UILabel *locationLabel;
@property (nonatomic, readwrite, weak) UIImageView *pinView;

@property (nonatomic, readwrite, weak) UITapGestureRecognizer *tapRecog;

@property (nonatomic, readwrite, weak) MainViewController *mainVC;
@property (nonatomic, readwrite, assign) DestinationViewState state;

@end

#define kWidthOfPinIcon 40.0f
@implementation SetDestinationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



- (void)setupIsPickup:(BOOL)isPickup
             parentVC:(MainViewController *)mainVC {
    self.isPickup = isPickup;
    self.mainVC = mainVC;
    CGRect frame = self.frame;
    CGSize size = frame.size;
    
    
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(kWidthOfPinIcon, 0, size.width - kWidthOfPinIcon, size.height)];
    locationLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    locationLabel.textColor = [UIColor blackColor];
    locationLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTapped)];
    [locationLabel addGestureRecognizer:tapRecog];
    
    UIImage *image = [UIImage imageNamed:isPickup?@"greenMapIcon.png":@"redMapIcon.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.clipsToBounds = YES;
    imageView.frame = CGRectMake(0, 0, kWidthOfPinIcon, size.height);
    
    [self addSubview:locationLabel];
    [self addSubview:imageView];
    self.locationLabel = locationLabel;
    self.pinView = imageView;
    
    [self clearOutDestination];
}

- (void)clearOutDestination {
    self.state = DestinationViewStateEmpty;
    self.locationLabel.text = @"Add Location...";
    if (self.isPickup) {
        [self.mainVC clearPickupLocation];
    } else {
        [self.mainVC clearDestinationLocation];
    }
    
}

- (void)setWithAddress:(NSString *)address {
    self.state = DestinationViewStateAddress;
    self.locationLabel.text = address;
}

- (void)setWithPin {
    self.state = DestinationViewStatePin;
    self.locationLabel.text = @"Pin Location";
}

- (void)buttonTapped {
    switch (self.state) {
        case DestinationViewStateEmpty:
        {
            LocationSearchViewController *vc = [[LocationSearchViewController alloc] initWithIsPickup:self.isPickup];
            [self.mainVC presentViewController:vc animated:YES completion:^{
                
            }];
            break;
        }
        case DestinationViewStatePin:
        {
            [self clearOutDestination];
            break;
        }
            
        case DestinationViewStateAddress:
        {
            [self clearOutDestination];
            break;
        }
            
        default:
            break;
    }
    
}

@end
