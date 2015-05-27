//
//  GlobalStateInterface.h
//  cabAgg
//
//  Created by Kanav Arora on 1/14/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class  MainViewController;
@interface GlobalStateInterface : NSObject

@property (nonatomic, readwrite, weak) MainViewController *mainVC;
@property (nonatomic, readwrite, assign) BOOL shouldOptimizeDestination;

+ (BOOL)areEqualLocations:(CLLocationCoordinate2D)loc1
                  andloc2:(CLLocationCoordinate2D)loc2;

@end

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#define USE_TEST_SERVER 0

#define USE_DEV_SERVER 0

extern GlobalStateInterface *globalStateInterface;