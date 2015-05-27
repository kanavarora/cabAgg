//
//  ResultInfo.m
//  cabAgg
//
//  Created by Kanav Arora on 1/15/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "ResultInfo.h"

#import "GlobalStateInterface.h"
#import "CabAggHttpClient.h"
#import "UberHTTPClient.h"
#import "MainViewController.h"

@implementation ResultInfo


+(UIColor *)backgroundColorForCabType:(CabType)cabType {
    switch (cabType) {
        case CabTypeLyftLine:
            return UIColorFromRGB(0xEA0B8C);
            
        case CabTypeLyft:
            return UIColorFromRGB(0xEA0B8C);
            
        case CabTypeUberPool:
            return [UIColor blackColor];
            
        case CabTypeUberX:
            return [UIColor blackColor];
    }
}

+ (NSString *)titleForCabType:(CabType)cabType {
    switch (cabType) {
        case CabTypeLyftLine:
            return @"LyftLine";
            
        case CabTypeLyft:
            return @"Lyft";
            
        case CabTypeUberPool:
            return @"UberPool";
            
        case CabTypeUberX:
            return @"UberX";
    }
}

- (NSString *)deepLinkUrl:(BOOL)isBestRoute {
    UberHTTPClient *uberClient = [UberHTTPClient sharedInstance];
    CLLocationCoordinate2D start = globalStateInterface.mainVC.pickupLocation;
    if (isBestRoute) {
        start = self.start;
    }
    switch (self.cabType) {
        case CabTypeLyftLine:
        {
            return [CabAggHttpClient urlForPickupLatitude:start.latitude
                                          pickupLongitude:start.longitude
                                             dropLatitude:self.end.latitude
                                            dropLongitude:self.end.longitude
                                               isLyftLine:YES];
        }
        case CabTypeLyft:
        {
            return [CabAggHttpClient urlForPickupLatitude:start.latitude
                                          pickupLongitude:start.longitude
                                             dropLatitude:self.end.latitude
                                            dropLongitude:self.end.longitude
                                               isLyftLine:NO];
        }
            
            
        case CabTypeUberPool:
        {
            return [uberClient urlForPickupLatitude:start.latitude
                                    pickupLongitude:start.longitude
                                       dropLatitude:self.end.latitude
                                      dropLongitude:self.end.longitude
                                            isUberX:NO];
        }
            
        case CabTypeUberX:
        {
            return [uberClient urlForPickupLatitude:start.latitude
                                    pickupLongitude:start.longitude
                                       dropLatitude:self.end.latitude
                                      dropLongitude:self.end.longitude
                                            isUberX:YES];
        }
            
    }
    return nil;
}
static BOOL isTesting = NO;

- (void)update {
    CabAggHttpClient *lyftClient = globalStateInterface.mainVC.lyftClient;
    UberHTTPClient *uberClient = [UberHTTPClient sharedInstance];
    switch (self.cabType) {
        case CabTypeLyftLine:
        {
            self.lowEstimate = self.highEstimate = lyftClient.bestPrice;
            self.actLowEstimate = self.actHighEstimate = lyftClient.actPrice;
            
            self.start = CLLocationCoordinate2DMake(lyftClient.bestLat, lyftClient.bestLon);
            self.end = CLLocationCoordinate2DMake(lyftClient.bestEndLat, lyftClient.bestEndLon);
            self.isRouteInvalid = !lyftClient.isLyftLineRouteValid;
            break;
        }
        case CabTypeLyft:
        {
            self.lowEstimate = self.highEstimate = [lyftClient getBestPrice];
            self.actLowEstimate = self.actHighEstimate = [lyftClient getActPrice];
            
            self.surgeMultiplier = [lyftClient getBestDyncPricing];
            self.actSurgeMultiplier = [lyftClient getActDyncPricing];
            
            self.start = CLLocationCoordinate2DMake(lyftClient.lyftBestLat, lyftClient.lyftBestLon);
            
            if (isTesting) {
                self.lowEstimate = self.highEstimate = 13.78f;
                self.actLowEstimate = self.actHighEstimate = 19.45f;
                self.surgeMultiplier = 0;
                self.actSurgeMultiplier = 50;
                self.start = CLLocationCoordinate2DMake(37.795756524245448, -122.43302515419013);
                lyftClient.lyftBestLat = 37.795756524245448;
                lyftClient.lyftBestLon = -122.43302515419013;
            }
            self.end = lyftClient.end;
            break;
        }
            
        case CabTypeUberPool:
        {
            self.lowEstimate = uberClient.bestPoolLowEstimate;
            self.highEstimate = uberClient.bestPoolHighEstimate;
            self.surgeMultiplier = uberClient.bestSurgeMultiplier;
            
            self.actLowEstimate = uberClient.actualPoolLowEstimate;
            self.actHighEstimate = uberClient.actualPoolHighEstimate;
            self.actSurgeMultiplier = uberClient.actualSurgeMultiplier;
            
            self.start = CLLocationCoordinate2DMake(uberClient.poolBestLat, uberClient.poolBestLon);
            self.end = uberClient.actualEnd;
            self.isRouteInvalid = uberClient.isPoolRouteInvalid || uberClient.isRouteInvalid;
            if (isTesting) {
                self.lowEstimate = 10;
                self.highEstimate = 12;
                self.actLowEstimate = 18;
                self.actHighEstimate = 20;
                self.start = CLLocationCoordinate2DMake(37.800030524094396, -122.43302515419013);
                uberClient.poolBestLat = 37.800030524094396;
                uberClient.poolBestLon = -122.43302515419013;
            }
            break;
        }
            
        case CabTypeUberX:
        {
            self.lowEstimate = uberClient.bestLowEstimate;
            self.highEstimate = uberClient.bestHighEstimate;
            self.surgeMultiplier = (uberClient.bestSurgeMultiplier - 1)*100;
            
            self.actLowEstimate = uberClient.actualLowEstimate;
            self.actHighEstimate = uberClient.actualHighEstimate;
            self.actSurgeMultiplier = (uberClient.actualSurgeMultiplier - 1)*100;
            
            self.start = CLLocationCoordinate2DMake(uberClient.bestLat, uberClient.bestLon);
            self.end = uberClient.actualEnd;
            self.isRouteInvalid = uberClient.isRouteInvalid;
            if (isTesting) {
                self.lowEstimate = 16;
                self.highEstimate = 18;
                self.actLowEstimate = 16;
                self.actHighEstimate = 18;
                self.start = CLLocationCoordinate2DMake(37.800030524094396, -122.43302515419013);
                uberClient.bestLat = 37.800030524094396;
                uberClient.bestLon = -122.43302515419013;
            }
            break;
        }
    }
}

- (float)differenceSurgePricing {
    switch (self.cabType) {
        case CabTypeLyftLine:
            return 0.0f;
        case CabTypeUberPool:
        {
            float diff = self.actSurgeMultiplier - self.surgeMultiplier;
            float discount = self.actHighEstimate - self.highEstimate;
            
            if (discount <= 0 || (self.highEstimate < 0 || self.highEstimate > 1000)) {
                return 0;
            } else if (diff > 0 && discount > 0) {
                return diff;
            }
            return 0;
        }
        case CabTypeLyft:
        case CabTypeUberX:
        {
            float diff = self.actSurgeMultiplier - self.surgeMultiplier;
            float discount = self.actHighEstimate - self.highEstimate;
            
            if (discount <= 0 || (self.highEstimate < 0 || self.highEstimate > 1000)) {
                return 0;
            } else if (diff > 0) {
                return diff;
            }
            return 0;
        }
    }
}

- (BOOL)isDone {
    CabAggHttpClient *lyftClient = globalStateInterface.mainVC.lyftClient;
    UberHTTPClient *uberClient = [UberHTTPClient sharedInstance];
    switch (self.cabType) {
        case CabTypeLyftLine:
        case CabTypeLyft:
            return lyftClient.isDone;
            
        case CabTypeUberPool:
        case CabTypeUberX:
            return uberClient.isDone;
            
    }
}

@end
