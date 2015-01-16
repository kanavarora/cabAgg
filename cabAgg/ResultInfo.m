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
        case CabTypeLyftLineWalk:
            return UIColorFromRGB(0xFF3399);
            
        case CabTypeLyftLineActual:
            return UIColorFromRGB(0xFF3399);
            
        case CabTypeUberPoolWalk:
            return [UIColor blackColor];
            
        case CabTypeUberPoolActual:
            return [UIColor blackColor];
            
        case CabTypeUberActual:
            return [UIColor blackColor];
            
        case CabTypeUberWalk:
            return [UIColor blackColor];
    }
}

+ (NSString *)titleForCabType:(CabType)cabType {
    switch (cabType) {
        case CabTypeLyftLineWalk:
            return @"LyftLine";
            
        case CabTypeLyftLineActual:
            return @"LyftLine";
            
        case CabTypeUberPoolWalk:
            return @"UberPool";
            
        case CabTypeUberPoolActual:
            return @"UberPool";
            
        case CabTypeUberActual:
            return @"UberX";
            
        case CabTypeUberWalk:
            return @"UberX";
    }
}

- (NSString *)deepLinkUrl {
    UberHTTPClient *uberClient = [UberHTTPClient sharedInstance];
    switch (self.cabType) {
        case CabTypeLyftLineActual:
        case CabTypeLyftLineWalk:
            return [CabAggHttpClient deepLinkUrl];
            
            
        case CabTypeUberPoolWalk:
        case CabTypeUberPoolActual:
            return [uberClient urlForPickupLatitude:self.start.latitude
                                    pickupLongitude:self.start.longitude
                                       dropLatitude:self.end.latitude
                                      dropLongitude:self.end.longitude
                                            isUberX:NO];
            
        case CabTypeUberActual:
        case CabTypeUberWalk:
            return [uberClient urlForPickupLatitude:self.start.latitude
                                    pickupLongitude:self.start.longitude
                                       dropLatitude:self.end.latitude
                                      dropLongitude:self.end.longitude
                                            isUberX:YES];
            
    }
    return nil;
}

- (void)update {
    CabAggHttpClient *lyftClient = globalStateInterface.mainVC.lyftClient;
    UberHTTPClient *uberClient = [UberHTTPClient sharedInstance];
    switch (self.cabType) {
        case CabTypeLyftLineWalk:
        {
            self.lowEstimate = self.highEstimate = lyftClient.bestPrice/100.0f;
            break;
        }
            
        case CabTypeLyftLineActual:
        {
            self.lowEstimate = self.highEstimate = lyftClient.actPrice/100.0f;
            break;
        }
            
        case CabTypeUberPoolWalk:
        {
            self.lowEstimate = uberClient.bestLowEstimate *0.8f;
            self.highEstimate = uberClient.bestHighEstimate*0.8f;
            self.surgeMultiplier = uberClient.bestSurgeMultiplier;
            self.start = CLLocationCoordinate2DMake(uberClient.bestLat, uberClient.bestLon);
            self.end = uberClient.actualEnd;
            break;
        }
            
        case CabTypeUberPoolActual:
        {
            self.lowEstimate = uberClient.actualLowEstimate*0.8f;
            self.highEstimate = uberClient.actualHighEstimate*0.8f;
            self.surgeMultiplier = uberClient.actualSurgeMultiplier;
            self.start = uberClient.actualStart;
            self.end = uberClient.actualEnd;
            break;
        }
            
        case CabTypeUberWalk:
        {
            self.lowEstimate = uberClient.bestLowEstimate;
            self.highEstimate = uberClient.bestHighEstimate;
            self.surgeMultiplier = uberClient.bestSurgeMultiplier;
            self.start = CLLocationCoordinate2DMake(uberClient.bestLat, uberClient.bestLon);
            self.end = uberClient.actualEnd;
            break;
        }
            
        case CabTypeUberActual:
        {
            self.lowEstimate = uberClient.actualLowEstimate;
            self.highEstimate = uberClient.actualHighEstimate;
            self.surgeMultiplier = uberClient.actualSurgeMultiplier;
            self.start = uberClient.actualStart;
            self.end = uberClient.actualEnd;
            break;
        }
    }
}

@end
