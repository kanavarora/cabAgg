//
//  ResultInfo.h
//  cabAgg
//
//  Created by Kanav Arora on 1/15/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

typedef enum {
    CabTypeLyftLineWalk = 0,
    CabTypeLyftLineActual,
    CabTypeUberPoolWalk,
    CabTypeUberPoolActual,
    CabTypeUberWalk,
    CabTypeUberActual,
} CabType;

@interface ResultInfo : NSObject

@property (nonatomic, readwrite, assign) CabType cabType;
@property (nonatomic, readwrite, assign) float lowEstimate;
@property (nonatomic, readwrite, assign) float highEstimate;
@property (nonatomic, readwrite, assign) float surgeMultiplier;
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D start;
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D end;


+(UIColor *)backgroundColorForCabType:(CabType)cabType;
+ (NSString *)titleForCabType:(CabType)cabType;
- (NSString *)deepLinkUrl;
- (void)update;

@end
