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
@property (nonatomic, readwrite, assign) float actualPoolLowEstimate;
@property (nonatomic, readwrite, assign) float actualPoolHighEstimate;


@property (nonatomic, readwrite, assign) float bestSurgeMultiplier;
@property (nonatomic, readwrite, assign) float bestLowEstimate;
@property (nonatomic, readwrite, assign) float bestHighEstimate;
@property (nonatomic, readwrite, assign) float bestPoolLowEstimate;
@property (nonatomic, readwrite, assign) float bestPoolHighEstimate;
@property (nonatomic, readwrite, assign) int bestI;
@property (nonatomic, readwrite, assign) int bestJ;
@property (nonatomic, readwrite, assign) double bestLon;
@property (nonatomic, readwrite, assign) double bestLat;
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D actualStart;
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D actualEnd;

@property (nonatomic, readonly, assign) BOOL isDone;
@property (nonatomic, readwrite, assign) BOOL isRouteInvalid;
@property (nonatomic, readwrite, assign) BOOL isPoolRouteInvalid;

- (NSString *)urlForPickupLatitude:(double)pickupLatitude
                   pickupLongitude:(double)pickupLongitude
                      dropLatitude:(double)dropLatitude
                     dropLongitude:(double)dropLongitude
                           isUberX:(BOOL)isUberX;
- (BOOL)canOpenDeepLinks;

- (void)getPriceEstimatesForStart:(CLLocationCoordinate2D)start
                              end:(CLLocationCoordinate2D)end
                 startDisNeighbor:(double)startDisNeighbor;

@end
