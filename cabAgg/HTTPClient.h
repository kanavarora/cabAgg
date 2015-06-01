//
//  HTTPClient.h
//  cabAgg
//
//  Created by Kanav Arora on 1/14/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import <MapKit/MapKit.h>

@interface HTTPClient : AFHTTPSessionManager

+ (HTTPClient *)sharedInstance;
- (void)getGeoCodeFor:(NSString *)address
        startLocation:(CLLocationCoordinate2D) startLocation
              success:(void (^)(NSArray *))successBlock;
- (void)getDirectionsFromStart:(CLLocationCoordinate2D)startLocation
                           end:(CLLocationCoordinate2D)endLocation
                       success:(void (^)(NSDictionary *))successBlock
                       failure:(void (^)())failureBlock;
- (void)startApp;
- (void)trackWithEventName:(NSString *)eventName
           eventProperties:(NSDictionary *)eventProperties;
@end
