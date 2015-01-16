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

@end
