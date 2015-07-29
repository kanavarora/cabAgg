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
#import "GlobalStateInterface.h"
#import "UIView+Border.h"

typedef enum {
    DestinationViewStateEmpty = 0,
    DestinationViewStateFilled,
    DestinationViewStateLocked,
} DestinationViewState;

@interface SetDestinationView ()

@property (nonatomic, readwrite, assign) BOOL isPickup;
@property (nonatomic, readwrite, weak) UILabel *locationLabel;
@property (nonatomic, readwrite, weak) UIImageView *pinView;

@property (nonatomic, readwrite, assign) CLLocationCoordinate2D pinLocation;

@property (nonatomic, readwrite, weak) UITapGestureRecognizer *tapRecog;

@property (nonatomic, readwrite, weak) MainViewController *mainVC;
@property (nonatomic, readwrite, assign) DestinationViewState state;

@property (nonatomic, readwrite, strong) CLGeocoder *geocoder;
@property (nonatomic, readwrite, assign) int count; // this is to take care of multiple geocode requests that might create a problem
@property (nonatomic, readwrite, assign) BOOL isSetOnce;

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
    self.geocoder = [[CLGeocoder alloc] init];
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
    locationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    

    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, ((size.height-image.size.height)/2.0f), image.size.width, image.size.height);
    //imageView.clipsToBounds = YES;
    //imageView.frame = CGRectMake(0, ((size.height-kHeightOfPinIcon)/2.0f), kWidthOfPinIcon, kHeightOfPinIcon);
    
    [self addSubview:locationLabel];
    [self addSubview:imageView];
    [UIView constraintView:locationLabel
               toSuperView:self
                    insets:UIEdgeInsetsMake(0, image.size.width, 0, 2)];
    self.locationLabel = locationLabel;
    self.pinView = imageView;
    
    // only for the start
    self.state = DestinationViewStateEmpty;
    if (!isPickup) {
        self.state = DestinationViewStateLocked;
    }
    if (self.isPickup) {
        self.locationLabel.text = @"Add Pickup";
    } else {
        self.locationLabel.text = @"Add Destination";
    }
}

- (void)centerOnLocationAndClearOutDestination {
    BOOL isAnimated = NO;
    if (self.isPickup) {
        isAnimated = [self.mainVC centerOnPickup];
    }else {
        isAnimated = [self.mainVC centerOnDestination];
    }
    /*
    if (isAnimated) {
        [self performSelector:@selector(clearOutDestination) withObject:nil afterDelay:0.5f];
    } else {
        [self clearOutDestination];
    }
     */
}

- (void)clearOutDestination {
    if (self.isPickup) {
        //self.locationLabel.text = @"Add Pickup";
        [self.mainVC clearPickupLocation];
    } else {
        //self.locationLabel.text = @"Add Destination";
        [self.mainVC clearDestinationLocation];
    }
    
}

- (void)setWithAddress:(NSString *)address location:(CLLocationCoordinate2D)location{
    self.count++;
    self.state = DestinationViewStateFilled;
    self.locationLabel.text = address;
    self.pinLocation = location;
    self.isSetOnce = YES;
    
}

- (void)setWithPin:(CLLocationCoordinate2D)location {
    if (self.state == DestinationViewStateFilled  && [GlobalStateInterface areEqualLocations:location andloc2:self.pinLocation]) {
        return; // dont need to do anything
    }
    self.state = DestinationViewStateFilled;
    self.locationLabel.text = @"Updating Location...";
    self.pinLocation = location;
    self.isSetOnce = YES;
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    self.count ++;
    int current = self.count;
    [self.geocoder reverseGeocodeLocation:loc completionHandler:
     
     //Getting Human readable Address from Lat long,,,
     
     ^(NSArray *placemarks, NSError *error) {
         //Get nearby address
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         //String to hold address
         NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
         //Print the location to console
         if (current == self.count) {
             self.locationLabel.text = locatedAt?locatedAt:@"";
         } else {
             NSLog(@"Did not update location");
         }
     }];
}

- (void)lockIt {
    self.state = DestinationViewStateLocked;
}

- (void)unlockIt {
    self.state = DestinationViewStateFilled;
}

- (void)buttonTapped {
    if (self.state != DestinationViewStateLocked) {
    LocationSearchViewController *vc = [[LocationSearchViewController alloc] initWithIsPickup:self.isPickup];
    [self.mainVC presentViewController:vc animated:YES completion:^{
        
    }];
    [self centerOnLocationAndClearOutDestination];
    } else {
        self.state = DestinationViewStateFilled;
        [globalStateInterface.mainVC unlockedLocation:self.isPickup];
    }
}

@end
