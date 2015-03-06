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
    switch (self.cabType) {
        case CabTypeLyftLine:
        case CabTypeLyft:
            return [CabAggHttpClient deepLinkUrl];
            
            
        case CabTypeUberPool:
        {
            CLLocationCoordinate2D start = globalStateInterface.mainVC.pickupLocation;
            if (isBestRoute) {
                start = self.start;
            }
            return [uberClient urlForPickupLatitude:start.latitude
                                    pickupLongitude:start.longitude
                                       dropLatitude:self.end.latitude
                                      dropLongitude:self.end.longitude
                                            isUberX:NO];
        }
            
        case CabTypeUberX:
        {
            CLLocationCoordinate2D start = globalStateInterface.mainVC.pickupLocation;
            if (isBestRoute) {
                start = self.start;
            }
            return [uberClient urlForPickupLatitude:start.latitude
                                    pickupLongitude:start.longitude
                                       dropLatitude:self.end.latitude
                                      dropLongitude:self.end.longitude
                                            isUberX:YES];
        }
            
    }
    return nil;
}

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
            
            self.start = CLLocationCoordinate2DMake(uberClient.bestLat, uberClient.bestLon);
            self.end = uberClient.actualEnd;
            self.isRouteInvalid = uberClient.isPoolRouteInvalid || uberClient.isRouteInvalid;
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
            break;
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
