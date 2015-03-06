//
//  GlobalStateInterface.m
//  cabAgg
//
//  Created by Kanav Arora on 1/14/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "GlobalStateInterface.h"

#import <MapKit/MapKit.h>

GlobalStateInterface *globalStateInterface;

@implementation GlobalStateInterface

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

#define fequal(a,b) (fabs((a) - (b)) < 0.00001)

+ (BOOL)areEqualLocations:(CLLocationCoordinate2D)loc1 andloc2:(CLLocationCoordinate2D)loc2 {
    return fequal(loc1.latitude, loc2.latitude) && fequal(loc1.longitude, loc2.longitude);
}
@end