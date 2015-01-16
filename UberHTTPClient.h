//
//  UberHTTPClient.h
//  cabAgg
//
//  Created by Kanav Arora on 1/7/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "AFHTTPSessionManager.h"

#import <GoogleMaps/GoogleMaps.h>

@interface UberHTTPClient : AFHTTPSessionManager

+ (UberHTTPClient *)sharedInstance;

@property (nonatomic, readwrite, assign) float actualSurgeMultiplier;
@property (nonatomic, readwrite, assign) float actualLowEstimate;
@property (nonatomic, readwrite, assign) float actualHighEstimate;

@property (nonatomic, readwrite, assign) float bestSurgeMultiplier;
@property (nonatomic, readwrite, assign) float bestLowEstimate;
@property (nonatomic, readwrite, assign) float bestHighEstimate;
@property (nonatomic, readwrite, assign) int bestI;
@property (nonatomic, readwrite, assign) int bestJ;
@property (nonatomic, readwrite, assign) float bestLon;
@property (nonatomic, readwrite, assign) float bestLat;
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D actualStart;
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D actualEnd;

- (NSString *)urlForPickupLatitude:(float)pickupLatitude
                   pickupLongitude:(float)pickupLongitude
                      dropLatitude:(float)dropLatitude
                     dropLongitude:(float)dropLongitude
                           isUberX:(BOOL)isUberX;
- (BOOL)canOpenDeepLinks;

- (void)getPriceEstimatesForStart:(CLLocationCoordinate2D)start
                              end:(CLLocationCoordinate2D)end
                 startDisNeighbor:(float)startDisNeighbor;

@end
