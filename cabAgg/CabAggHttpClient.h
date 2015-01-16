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

@property (nonatomic, readwrite, assign) int totalReq;
@property (nonatomic, readwrite, assign) int bestI;
@property (nonatomic, readwrite, assign) int bestJ;
@property (nonatomic, readwrite, assign) int bestK;
@property (nonatomic, readwrite, assign) int bestL;
@property (nonatomic, readwrite, assign) float bestLat;
@property (nonatomic, readwrite, assign) float bestLon;
@property (nonatomic, readwrite, assign) float bestEndLat;
@property (nonatomic, readwrite, assign) float bestEndLon;
@property (nonatomic, readwrite, assign) float bestPrice;
@property (nonatomic, readwrite, assign) float actPrice;
+ (NSString *)deepLinkUrl;

- (void)getInfoForMarker:(NSDictionary *)marker
           andDestMarker:(NSDictionary *)destMarker
            successBlock:(void (^)(float))successBlock;
- (void)optimizeForStart:(CLLocationCoordinate2D)start
                     end:(CLLocationCoordinate2D)end
        startDisNeighbor:(float)startDisNeighbor
          endDisNeighbor:(float)endDisNeighbor;
@end
