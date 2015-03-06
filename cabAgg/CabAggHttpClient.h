//
//  CabAggHttpClient.h
//  cabAgg
//
//  Created by Kanav Arora on 1/4/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GoogleMaps/GoogleMaps.h>

@interface CabAggHttpClient : NSObject

@property (nonatomic, readwrite, assign) CLLocationCoordinate2D start;
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D end;

@property (nonatomic, readwrite, assign) int totalReq;
@property (nonatomic, readwrite, assign) double bestLat;
@property (nonatomic, readwrite, assign) double bestLon;
@property (nonatomic, readwrite, assign) double bestEndLat;
@property (nonatomic, readwrite, assign) double bestEndLon;
@property (nonatomic, readwrite, assign) float bestPrice;
@property (nonatomic, readwrite, assign) float actPrice;
@property (nonatomic, readwrite, strong) NSDictionary *lyftActPrice;
@property (nonatomic, readwrite, strong) NSDictionary *lyftBestPrice;
@property (nonatomic, readwrite, assign) double lyftBestLat;
@property (nonatomic, readwrite, assign) double lyftBestLon;
@property (nonatomic, readwrite, strong) NSDictionary *lyftActDirections;
@property (nonatomic, readwrite, strong) NSDictionary *lyftBestDirections;
@property (nonatomic, readwrite, assign) BOOL isLyftLineRouteValid;


@property (nonatomic, readonly, assign) BOOL isDone;

+ (NSString *)deepLinkUrl;

- (void)getInfoForMarker:(NSDictionary *)marker
           andDestMarker:(NSDictionary *)destMarker
            successBlock:(void (^)(float, BOOL, NSDictionary *, NSDictionary *))successBlock
            failureBlock:(void (^)())failureBlock;
- (void)optimizeForStart:(CLLocationCoordinate2D)start
                     end:(CLLocationCoordinate2D)end
        startDisNeighbor:(float)startDisNeighbor
          endDisNeighbor:(float)endDisNeighbor;

- (float)getBestDyncPricing;
- (float)getActDyncPricing;
- (float)getBestPrice;
- (float)getActPrice;
@end
