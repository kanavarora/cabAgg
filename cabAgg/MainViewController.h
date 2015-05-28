//
//  MainViewController.h
//  cabAgg
//
//  Created by Kanav Arora on 1/14/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class CabAggHttpClient;

@interface MainViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, readonly, strong) CabAggHttpClient *lyftClient;
@property (nonatomic, readonly, assign) CLLocationCoordinate2D pickupLocation;
@property (nonatomic, readonly, assign) CLLocationCoordinate2D destinationLocation;

- (CLLocationCoordinate2D)currentMapLocation;
- (void)clearPickupLocation;
- (void)clearDestinationLocation;
- (BOOL)centerOnPickup; // returns whether there is any need to center anywhere
- (BOOL)centerOnDestination;
- (CLLocationCoordinate2D)centerOfMap;
- (void)centerMapOnLocation:(CLLocationCoordinate2D)loc;
- (void)updatePickupLocation:(CLLocationCoordinate2D)pickupLocation
                     address:(NSString *)address
                  moveRegion:(BOOL)moveRegion;
- (void)updateDestinationLocation:(CLLocationCoordinate2D)destinationLocation
                          address:(NSString *)address
                       moveRegion:(BOOL)moveRegion;
- (void)reoptimize;

@end
