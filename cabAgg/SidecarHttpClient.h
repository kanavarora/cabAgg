//
//  SidecarHttpClient.h
//  cabAgg
//
//  Created by Kanav Arora on 1/8/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import <GoogleMaps/GoogleMaps.h>

@interface SidecarHttpClient : AFHTTPSessionManager

+ (SidecarHttpClient *)sharedInstance;
- (void)appLaunch;
- (void)getForStart:(CLLocationCoordinate2D)start
                end:(CLLocationCoordinate2D)end
            success:(void (^)())successBlock;

@end
