//
//  CachedPolyline.h
//  cabAgg
//
//  Created by Kanav Arora on 1/29/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CachedPolyline : NSObject

- (id)initWithStart:(CLLocationCoordinate2D)start
                end:(CLLocationCoordinate2D)end;

- (MKPolyline *)polyline;
- (BOOL)shouldUpdateWithStart:(CLLocationCoordinate2D)start
                          end:(CLLocationCoordinate2D)end;
- (void)updateWithStart:(CLLocationCoordinate2D)start
                    end:(CLLocationCoordinate2D)end;
@end
