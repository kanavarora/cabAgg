//
//  SetDestinationView.h
//  cabAgg
//
//  Created by Kanav Arora on 1/14/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

typedef enum {
    DestinationViewStateEmpty = 0,
    DestinationViewStatePin,
    DestinationViewStateAddress,
} DestinationViewState;

@class MainViewController;
@interface SetDestinationView : UIView

@property (nonatomic, readonly, assign) DestinationViewState state;

- (void)setupIsPickup:(BOOL)isPickup
             parentVC:(MainViewController *)mainVC;
- (void)setWithAddress:(NSString *)address location:(CLLocationCoordinate2D)location;
- (void)setWithPin:(CLLocationCoordinate2D)location;
@property (nonatomic, readonly, assign) BOOL isSetOnce;
@property (nonatomic, readonly, assign) CLLocationCoordinate2D pinLocation;

@end
