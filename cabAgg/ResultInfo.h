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
    CabTypeLyftLine =0,
    CabTypeLyft,
    CabTypeUberPool,
    CabTypeUberX,
} CabType;

@interface ResultInfo : NSObject

@property (nonatomic, readwrite, assign) CabType cabType;
@property (nonatomic, readwrite, assign) float actLowEstimate;
@property (nonatomic, readwrite, assign) float actHighEstimate;
@property (nonatomic, readwrite, assign) float actSurgeMultiplier;

@property (nonatomic, readwrite, assign) float lowEstimate;
@property (nonatomic, readwrite, assign) float highEstimate;
@property (nonatomic, readwrite, assign) float surgeMultiplier;

@property (nonatomic, readwrite, assign) BOOL isRouteInvalid;

@property (nonatomic, readwrite, assign) CLLocationCoordinate2D start;
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D end;


+ (UIColor *)backgroundColorForCabType:(CabType)cabType;
+ (NSString *)titleForCabType:(CabType)cabType;
- (NSString *)deepLinkUrl:(BOOL)isBestRoute;
- (void)update;
- (BOOL)isDone;
- (float)differenceSurgePricing;

@end
