//
//  CachedPolyline.m
//  cabAgg
//
//  Created by Kanav Arora on 1/29/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "CachedPolyline.h"


@interface CachedPolyline ()

@property (nonatomic, readwrite, assign) CLLocationCoordinate2D start;
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D end;

@property (nonatomic, readwrite, strong) MKPolyline *cachedPolyline;

@end

@implementation CachedPolyline

- (id)initWithStart:(CLLocationCoordinate2D)start
                end:(CLLocationCoordinate2D)end {
    if (self = [super init]) {
        _start = start;
        _end = end;
        [self setupLine];
    }
    return self;
}

- (void)setupLine {
    if ([self areEqualLoc1:self.start loc2:self.end]) {
        self.cachedPolyline = nil;
        return;
    }
    CLLocationCoordinate2D* pointArr = malloc(sizeof(CLLocationCoordinate2D) * 2);
    pointArr[0] = self.start;
    pointArr[1] = self.end;
    
    self.cachedPolyline = [MKPolyline polylineWithCoordinates:pointArr count:2];
    free(pointArr);
}

- (BOOL)areEqualLoc1:(CLLocationCoordinate2D)loc1
                loc2:(CLLocationCoordinate2D)loc2 {
    float epsilon = 0.000001f;
    return (fabs(loc1.latitude - loc2.latitude) <= epsilon &&
            fabs(loc1.longitude - loc2.longitude) <= epsilon);
}

- (BOOL)shouldUpdateWithStart:(CLLocationCoordinate2D)start
                          end:(CLLocationCoordinate2D)end {
    return !([self areEqualLoc1:self.start loc2:start] &&
             [self areEqualLoc1:self.end loc2:end]);
}

- (void)updateWithStart:(CLLocationCoordinate2D)start
                    end:(CLLocationCoordinate2D)end {
    self.start = start;
    self.end = end;
    // assumes old polyline will be removed
    [self setupLine];
}

- (MKPolyline *)polyline {
    return self.cachedPolyline;
}

@end
