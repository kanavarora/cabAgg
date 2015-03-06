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
    
    
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil
                                                               reuseIdentifier:@"tmp3"];
    pin.pinColor = MKPinAnnotationColorGreen;
    UIImage *greenImage = pin.image;
    pin.pinColor = MKPinAnnotationColorRed;
    UIImage *redImage = pin.image;
    
    UIImage *image = isPickup?greenImage:redImage;
    
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(image.size.width, 0,
                                                                       size.width - image.size.width, size.height)];
    locationLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    locationLabel.textColor = [UIColor blackColor];
    locationLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTapped)];
    [locationLabel addGestureRecognizer:tapRecog];
    

    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, ((size.height-image.size.height)/2.0f), image.size.width, image.size.height);
    //imageView.clipsToBounds = YES;
    //imageView.frame = CGRectMake(0, ((size.height-kHeightOfPinIcon)/2.0f), kWidthOfPinIcon, kHeightOfPinIcon);
    
    [self addSubview:locationLabel];
    [self addSubview:imageView];
    self.locationLabel = locationLabel;
    self.pinView = imageView;
    
    [self clearOutDestination];
}

- (void)centerOnLocationAndClearOutDestination {
    BOOL isAnimated = NO;
    if (self.isPickup) {
        isAnimated = [self.mainVC centerOnPickup];
    }else {
        isAnimated = [self.mainVC centerOnDestination];
    }
    if (isAnimated) {
        [self performSelector:@selector(clearOutDestination) withObject:nil afterDelay:0.5f];
    } else {
        [self clearOutDestination];
    }
}

- (void)clearOutDestination {
    self.state = DestinationViewStateEmpty;
    if (self.isPickup) {
        self.locationLabel.text = @"Add Pickup";
        [self.mainVC clearPickupLocation];
    } else {
        self.locationLabel.text = @"Add Destination";
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
            [self centerOnLocationAndClearOutDestination];
            break;
        }
            
        case DestinationViewStateAddress:
        {
            [self centerOnLocationAndClearOutDestination];
            break;
        }
            
        default:
            break;
    }
    
}

@end
