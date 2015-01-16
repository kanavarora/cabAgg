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

- (CLLocationCoordinate2D)currentMapLocation;
- (void)clearPickupLocation;
- (void)clearDestinationLocation;
- (void)updatePickupLocation:(CLLocationCoordinate2D)pickupLocation
                     address:(NSString *)address
                  moveRegion:(BOOL)moveRegion;
- (void)updateDestinationLocation:(CLLocationCoordinate2D)destinationLocation
                          address:(NSString *)address
                       moveRegion:(BOOL)moveRegion;
- (void)reoptimize;

@end
