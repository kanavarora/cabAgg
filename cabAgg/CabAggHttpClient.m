//
//  CabAggHttpClient.m
//  cabAgg
//
//  Created by Kanav Arora on 1/4/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "CabAggHttpClient.h"
#import "AFHTTPRequestOperationManager.h"
#import "GlobalStateInterface.h"


#define kLyftToken1 @"lyftToken eyJpZCI6IjU0YjM0ZTVhYzRjNWFhMDczZGQ4Mjk2MSIsInRzIjoiMjAxNS0wMS0xMiAwNjo0MDozOSIsInR2IjoxLCJzIjoiZDI4YjAyZmQ1N2RkZGU4NDYwYmNhMjIwYjhiNjUwZTgxY2I3YThhZGUwN2EwMzEyYTgxZWUxZGEwZDA1YjQ4NiJ9"

#define kLyftToken2 @"lyftToken eyJpZCI6IjUxNTZiMzBjOTM4MDYxZTA0NDAwMDI1ZiIsInRzIjoiMjAxNS0wMS0xMiAwNDo1MDo0OSIsInR2IjoxLCJzIjoiY2I5OWFkYmVjMDE3NTQyMjI2ZDMyZDFkOWE2ZWRiNDQ4N2YyN2FiYjk0ZmQwZjJhMzBiNzZkNjliNmNiMTI3MSJ9"
@interface CabAggHttpClient ()

@property (nonatomic, readwrite, strong) AFHTTPRequestOperationManager *manager;
@end

@implementation CabAggHttpClient

- (id)init {
    if (self = [super init]) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        //[manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        //[manager.operationQueue setMaxConcurrentOperationCount:1];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        //[manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        //[manager.requestSerializer setValue:kLyftToken1 forHTTPHeaderField:@"Authorization"];
        /*
        [manager.requestSerializer setValue:@"eyJkIjoiZDM5MDYyYzYzM2UyMzMyOTA5NmVhZGYyOGUwMjY0YjIiLCJiIjoiRUYzQUM0NDUtQkJBMS00MDI5LUE0RUItMTE1NEUwQjFCREFEIiwiZSI6IjlGMDYzQ0IyLThGOTctNDYxMS1BQ0IzLTA3MDIyMkZBNTdBMiIsImMiOiIzNTFkODIwOWE2YjMxNDMzNWRmNmViZDc5NzI0MGZkZSJ9" forHTTPHeaderField:@"X-session"];*/
        //[manager.requestSerializer setValue:@"iPhone7,2" forHTTPHeaderField:@"User-Device"];
        //[manager.requestSerializer setValue:@"AT&T" forHTTPHeaderField:@"X-Carrier"];
        //[manager.requestSerializer setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
        //[manager.requestSerializer setValue:@"application/vnd.lyft.app+json;version=23" forHTTPHeaderField:@"Accept"];
       // [manager.requestSerializer setValue:@"api.lyft.com" forHTTPHeaderField:@"Host"];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.manager = manager;
    }
    return self;
}

+ (NSString *)deepLinkUrl {
    NSString *url = [NSString stringWithFormat:@"lyft://"];
    return url;
}

- (void)getInfoForMarker2:(NSDictionary *)marker
           andDestMarker:(NSDictionary *)destMarker
            successBlock:(void (^)(float))successBlock
{

    NSDictionary *params = @{@"locations": [NSArray array],
                             //@"appInfoRevision" : @"c1ae00892e051f1dc4beccc442b9441f",
                             @"rideType" : @"courier",
                             @"marker" : marker,
                             @"markerDestination" : destMarker};
    
    [self.manager PUT:@"https://api.lyft.com/users/810610452/location" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        float toRtn = -1.0f;
        NSDictionary *preRides = responseObject[@"preRideInfo"];
        if (preRides) {
            NSDictionary *recommendedMoney = preRides[@"fixedFare"][@"recommendedTotalMoney"];
            if (recommendedMoney) {
                id amount = recommendedMoney[@"amount"];
                if (amount) {
                    toRtn = [amount floatValue];
                }
            }
        }
        if (successBlock) {
            successBlock(toRtn);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
       // NSLog(@"%.2f,%.2f", [destMarker[@"lat"] floatValue], [destMarker[@"lng"] floatValue]);
        successBlock(-1.0f);
    }];
}

- (void)getInfoForMarker:(NSDictionary *)marker
           andDestMarker:(NSDictionary *)destMarker
            successBlock:(void (^)(float))successBlock
{
    NSDictionary *params = @{@"startLat" : marker[@"lat"],
                             @"startLon" : marker[@"lng"],
                             @"endLat" : destMarker[@"lat"],
                             @"endLon" : destMarker[@"lng"]};
#if USE_TEST_SERVER
    NSString *baseUrl = @"http://localhost:8080/lyft";
#else
    NSString *baseUrl = @"http://golden-context-823.appspot.com/lyft";
#endif
    [self.manager GET:baseUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject[@"error"]) {
            successBlock(-1.0f);
        } else {
            successBlock([responseObject[@"price"] floatValue]);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        successBlock(-1.0f);
    }];
}

- (void)optimizeForStart:(CLLocationCoordinate2D)start
                     end:(CLLocationCoordinate2D)end
        startDisNeighbor:(float)startDisNeighbor
          endDisNeighbor:(float)endDisNeighbor {
    float metersPerLat = 111111.0f;
    float metersPerLon = 111111* cosf(start.latitude);
    
    float latDegNeigh = startDisNeighbor/metersPerLat;
    float lonDegNeigh = startDisNeighbor/metersPerLon;
    
    float latDegEndNeigh = endDisNeighbor/metersPerLat;
    float lonDegEndNeigh = endDisNeighbor/metersPerLon;
    
    self.bestI = -1;
    self.bestJ = -1;
    self.bestK = -1;
    self.bestL = -1;
    self.bestPrice = 100000.0f;
    self.bestLon = start.longitude;
    self.bestLat = start.latitude;
    self.bestEndLon = end.longitude;
    self.bestEndLat = end.latitude;
    
    BOOL calculateStart = startDisNeighbor >40.0f;
    BOOL calculateEnd = endDisNeighbor > 40.0f;
    
    for (int i=(calculateStart?-1:0); i<=(calculateStart?1:0) ; i++) {
        for (int j=(calculateStart?-1:0); j<=(calculateStart?1:0) ; j++) {
            
            
            float lat = start.latitude + (i*latDegNeigh);
            float lon = start.longitude + (j*lonDegNeigh);
            
            if (abs(i*j) == 1) {
                lat = start.latitude + (i* sqrt(0.5) * latDegNeigh);
                lon = start.longitude + (j*sqrt(0.5) * lonDegNeigh);
            }
            
            //  float endLat = end.latitude + (k*latDegEndNeigh);
            // float endLon = end.longitude + (l*lonDegEndNeigh);
            float endLat = end.latitude;
            float endLon = end.longitude;
            
            NSDictionary *startLocation = @{@"lat" : @(lat),
                                            @"lng" : @(lon)};
            NSDictionary *endLocation = @{@"lat" : @(endLat),
                                          @"lng" : @(endLon)};
            
            [self getInfoForMarker:startLocation andDestMarker:endLocation successBlock:^(float dollars) {
                if (dollars == -1.0f) {
                    return;
                }
                if (i==0 && j==0) {
                    self.actPrice = dollars;
                }
                if (dollars < self.bestPrice || ((dollars == self.bestPrice) && (i==0 && j==0))) {
                    self.bestPrice = dollars;
                    self.bestI = i;
                    self.bestJ = j;
                    
                    self.bestLat = lat;
                    self.bestLon = lon;
                }
            }];
        }
    }
    
    
    for (int k=(calculateEnd?-1:0); k<=(calculateEnd?1:0) ; k++) {
        for (int l=(calculateEnd?-1:0); l<=(calculateEnd?1:0) ; l++) {
            
            float lat = start.latitude;
            float lon = start.longitude;
            
            float endLat = end.latitude + (k*latDegEndNeigh);
            float endLon = end.longitude + (l*lonDegEndNeigh);
            
            if (abs(k*l)==1) {
                endLat = end.latitude + (k* sqrt(0.5) *latDegEndNeigh);
                endLon = end.longitude + (l*sqrt(0.5)*lonDegEndNeigh);
            }
            
            NSDictionary *startLocation = @{@"lat" : @(lat),
                                            @"lng" : @(lon)};
            NSDictionary *endLocation = @{@"lat" : @(endLat),
                                          @"lng" : @(endLon)};
            
            [self getInfoForMarker:startLocation andDestMarker:endLocation successBlock:^(float dollars) {
                if (dollars == -1.0f) {
                    return;
                }
                
                if (dollars < self.bestPrice || ((dollars == self.bestPrice) && (k==0 && l==0))) {
                    self.bestPrice = dollars;
                    self.bestK = k;
                    self.bestL = l;
                    
                    self.bestEndLat = endLat;
                    self.bestEndLon = endLon;
                }
            }];
        }
    }
}


/*
- (void)optimize2ForStart:(CLLocationCoordinate2D)start
                     end:(CLLocationCoordinate2D)end
        startDisNeighbor:(float)startDisNeighbor
          endDisNeighbor:(float)endDisNeighbor {
    self.totalReq = 0;
    
    float metersPerLat = 111111.0f;
    float metersPerLon = 111111* cosf(start.latitude);
    
    float latDegNeigh = startDisNeighbor/metersPerLat;
    float lonDegNeigh = startDisNeighbor/metersPerLon;
    
    float latDegEndNeigh = endDisNeighbor/metersPerLat;
    float lonDegEndNeigh = endDisNeighbor/metersPerLon;
    
    self.bestI = -1;
    self.bestJ = -1;
    self.bestK = -1;
    self.bestL = -1;
    self.bestPrice = 100000.0f;
    self.bestLon = start.longitude;
    self.bestLat = start.latitude;
    self.bestEndLon = end.longitude;
    self.bestEndLat = end.latitude;
    
    for (int i=-1; i<=1 ; i++) {
        for (int j=-1; j<=1 ; j++) {
            for (int k = -1; k <=1; k++) {
                for (int l = -1; l<=1; l++) {
                    
                    float lat = start.latitude + (i*latDegNeigh);
                    float lon = start.longitude + (j*lonDegNeigh);
                    
                    float endLat = end.latitude + (k*latDegEndNeigh);
                    float endLon = end.longitude + (l*lonDegEndNeigh);
                    
                    NSDictionary *startLocation = @{@"lat" : @(lat),
                                                    @"lng" : @(lon)};
                    NSDictionary *endLocation = @{@"lat" : @(endLat),
                                                  @"lng" : @(endLon)};
                    
                    [self getInfoForMarker:startLocation andDestMarker:endLocation successBlock:^(float dollars) {
                        self.tot++;
                        if (dollars == -1.0f) {
                            NSLog(@"%d", self.tot);
                            return;
                        }
                        NSLog(@"%d", self.tot);
                        if (i==0 && j==0 && k==0 && l==0) {
                            self.actPrice = dollars;
                        }
                        if (dollars < self.bestPrice || ((dollars == self.bestPrice) && (i==0 && j==0))) {
                            self.bestPrice = dollars;
                            self.bestI = i;
                            self.bestJ = j;
                            self.bestK = k;
                            self.bestL = l;
                            
                            self.bestLat = lat;
                            self.bestLon = lon;
                            self.bestEndLon = endLon;
                            self.bestEndLat = endLat;
                        }
                    }];
                }
            }
        }
    }
}
*/
@end
