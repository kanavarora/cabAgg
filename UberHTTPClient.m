//
//  UberHTTPClient.m
//  cabAgg
//
//  Created by Kanav Arora on 1/7/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "UberHTTPClient.h"
#import "GlobalStateInterface.h"

@interface UberHTTPClient ()

@property (nonatomic, readwrite, assign) int numRequests; // to keep track what id of bulk request we doing

@property (nonatomic, readwrite, assign) double startDisNeigh;
@property (nonatomic, readwrite, assign) int queuedRequests;
@property (nonatomic, readwrite, assign) BOOL isDone;

@end


@implementation UberHTTPClient

#define kUberClientID @"lHpulRd2-QygzWuKtYPjS2s-QU4N-YyU"
#define kUberXProductId @"a1111c8c-c720-46c3-8534-2fcdd730040d"
#define kUberPoolProductId @"26546650-e557-4a7b-86e7-6a3942445247"

/// Rate limit of 1000 requests an hour

+ (UberHTTPClient *)sharedInstance {
    static UberHTTPClient *_sharedUberHTTPClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
#if USE_TEST_SERVER
        NSString *baseUrl = @"http://localhost:8080/";
#else
        NSString *baseUrl = @"http://golden-context-823.appspot.com/";
#endif
        _sharedUberHTTPClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
    });
    
    return _sharedUberHTTPClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        NSMutableSet *acceptableContentTypes = [self.responseSerializer.acceptableContentTypes mutableCopy];
        [acceptableContentTypes addObject:@"text/html"];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithSet:acceptableContentTypes];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return self;
}

- (void)getPriceEstimateForStartLatitude:(double)startLatitude
                          startLongitude:(double)startLongitude
                             endLatitude:(double)endLatitude
                            endLongitude:(double)endLongitude
                                 success:(void (^)(float, float, float, float, float))successBlock
                                 failure:(void (^)())failureBlock {
    NSDictionary *params = @{@"startLat" : @(startLatitude),
                             @"startLon" : @(startLongitude),
                             @"endLat" : @(endLatitude),
                             @"endLon" : @(endLongitude)};
    [self GET:@"api/v1/uber" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if (!responseObject[@"error"]) {
            float lowEstimate = [responseObject[@"lowEstimate"] floatValue];
            float highEstimate = [responseObject[@"highEstimate"] floatValue];
            float surgeMultiplier = [responseObject[@"surgeMultiplier"] floatValue];
            float lowPoolEstimate = [responseObject[@"lowPoolEstimate"] floatValue];
            float highPoolEstimate = [responseObject[@"highPoolEstimate"] floatValue];
            BOOL uberPoolRouteValid = [responseObject[@"uberPoolRouteValid"] boolValue];
            if (!uberPoolRouteValid) {
                self.isPoolRouteInvalid = YES;
            }
            successBlock(lowEstimate, highEstimate, surgeMultiplier,
                         lowPoolEstimate, highPoolEstimate);
            return;
        } else {
            return failureBlock();
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failureBlock) failureBlock();
    }];
    
}

- (BOOL)shouldUpdateX:(float)lowEstimate
         highEstimate:(float)highEstimate
      surgeMultiplier:(float)surgeMultiplier
                  dis:(double)dis {
    float bestAvgEstimate = (self.bestLowEstimate + self.bestHighEstimate)/2.0f;
    float avgEstimate = (lowEstimate + highEstimate)/2.0f;
    
    BOOL shouldUpdateX = NO;
    if (surgeMultiplier < self.bestSurgeMultiplier) {
        shouldUpdateX = YES;
    } else if (surgeMultiplier == self.bestSurgeMultiplier) {
        if (dis < self.bestDis) {
            shouldUpdateX = YES;
        } else if ((dis == self.bestDis) && (avgEstimate < bestAvgEstimate)) {
            shouldUpdateX = YES;
        }
    }
    return shouldUpdateX;
}

- (BOOL)shouldUpdatePool:(float)lowEstimate
            highEstimate:(float)highEstimate
         surgeMultiplier:(float)surgeMultiplier
                     dis:(double)dis {
    float bestAvgEstimate = (self.bestPoolLowEstimate + self.bestPoolHighEstimate)/2.0f;
    float avgEstimate = (lowEstimate + highEstimate)/2.0f;
    
    BOOL shouldUpdatePool = NO;
    if (bestAvgEstimate <= avgEstimate) {
        return NO;
    }
    if (surgeMultiplier < self.bestSurgeMultiplier) {
        shouldUpdatePool = YES;
    } else if (surgeMultiplier == self.bestSurgeMultiplier) {
        if (dis < self.poolBestDis) {
            shouldUpdatePool = YES;
        } else if ((dis == self.poolBestDis) && (avgEstimate < bestAvgEstimate)) {
            shouldUpdatePool = YES;
        }
    }
    return shouldUpdatePool;
}


- (void)getPriceEstimatesForStart:(CLLocationCoordinate2D)start
                              end:(CLLocationCoordinate2D)end
                 startDisNeighbor:(double)startDisNeighbor {
    self.isRouteInvalid = NO;
    self.startDisNeigh = startDisNeighbor;
    self.actualEnd = end;
    self.actualStart = start;
    self.numRequests++;
    
    self.bestLowEstimate = 100000.0f;
    self.bestHighEstimate = 1000000.0f;
    self.bestPoolLowEstimate = 100000.0f;
    self.bestPoolHighEstimate = 1000000.0f;
    
    self.bestSurgeMultiplier = 100.0f;
    self.actualLowEstimate = self.actualHighEstimate = self.actualSurgeMultiplier = 0.0f;
    self.actualPoolLowEstimate = self.actualPoolHighEstimate = 0.0f;
    
    self.bestDis = self.poolBestDis = 0;
    
    self.bestLat = start.latitude;
    self.bestLon = start.longitude;
    self.queuedRequests = 0 ;
    self.isDone = NO;
    
    [self getActual];
}

- (void)getActual {
    int currentRequest = self.numRequests;
    [self getPriceEstimateForStartLatitude:self.actualStart.latitude startLongitude:self.actualStart.longitude endLatitude:self.actualEnd.latitude endLongitude:self.actualEnd.longitude success:^(float lowEstimate, float highEstimate, float surgeMultiplier, float lowPoolEstimate, float highPoolEstimate) {
        if (currentRequest != self.numRequests)
            return;
        self.actualLowEstimate = self.bestLowEstimate = lowEstimate;
        self.actualHighEstimate = self.bestHighEstimate = highEstimate;
        self.actualSurgeMultiplier = self.bestSurgeMultiplier = surgeMultiplier;
        self.actualPoolLowEstimate = self.bestPoolLowEstimate = lowPoolEstimate;
        self.actualPoolHighEstimate = self.bestPoolHighEstimate = highPoolEstimate;
        self.bestDis = 0;
        self.poolBestDis = 0;
        self.bestLat = self.poolBestLat = self.actualStart.latitude;
        self.bestLon = self.poolBestLon = self.actualStart.longitude;
        [self optimizeForStart];
    } failure:^{
        self.isDone = YES;
        self.isRouteInvalid = YES;
    }];
}

- (void)optimizeForStart {
    double metersPerLat = 111111.0f;
    double metersPerLon = 111111* cosf(self.actualStart.latitude);
    double startDisNeighbor = self.startDisNeigh;
    
    double latDegNeigh = startDisNeighbor/metersPerLat;
    double lonDegNeigh = startDisNeighbor/metersPerLon;
    if (startDisNeighbor < 40.0f) {
        self.isDone = YES;
        return;
    }
    
    int currentRequest = self.numRequests;
    
    for (int i=-1; i<=1; i++) {
        for (int j=-1; j<=1; j++) {
            if (i==0 && j==0) {
                continue;
            }
            double lat = self.actualStart.latitude + (i*latDegNeigh);
            double lon = self.actualStart.longitude + (j*lonDegNeigh);
            
            if (abs(i*j) == 1) {
                lat = self.actualStart.latitude + (i* sqrt(0.5) * latDegNeigh);
                lon = self.actualStart.longitude + (j*sqrt(0.5) * lonDegNeigh);
            }
            self.queuedRequests++;
            [self getPriceEstimateForStartLatitude:lat startLongitude:lon endLatitude:self.actualEnd.latitude endLongitude:self.actualEnd.longitude success:^(float lowEstimate, float highEstimate, float surgeMultiplier, float lowPoolEstimate, float highPoolEstimate) {
                if (currentRequest != self.numRequests)
                    return;
                
                if ([self shouldUpdateX:lowEstimate highEstimate:highEstimate surgeMultiplier:surgeMultiplier dis:startDisNeighbor]) {
                    self.bestDis = startDisNeighbor;
                    self.bestLat = lat;
                    self.bestLon = lon;
                    self.bestLowEstimate = lowEstimate;
                    self.bestHighEstimate = highEstimate;
                    self.bestSurgeMultiplier = surgeMultiplier;
                }
                
                if ([self shouldUpdatePool:lowPoolEstimate highEstimate:highPoolEstimate surgeMultiplier:surgeMultiplier dis:startDisNeighbor]) {
                    self.poolBestDis = startDisNeighbor;
                    self.poolBestLat = lat;
                    self.poolBestLon = lon;
                    self.bestPoolLowEstimate = lowPoolEstimate;
                    self.bestPoolHighEstimate = highPoolEstimate;
                }
                
                self.queuedRequests--;
                [self checkIfDone];
                
            } failure:^{
                self.queuedRequests--;
                [self checkIfDone];
            }];
        }
    }

}

- (void)checkIfDone {
    if (self.queuedRequests == 0) {
        [self furtherOptimizeForStart];
    }
}

- (void)furtherOptimizeForStart {
    CLLocationCoordinate2D bestUberStart = CLLocationCoordinate2DMake(self.bestLat, self.bestLon);
    if ([GlobalStateInterface areEqualLocations:bestUberStart andloc2:self.actualStart]) {
        self.isDone = YES;
    } else {
        float lat = (self.bestLat + self.actualStart.latitude)/2.0f;
        float lon = (self.bestLon + self.actualStart.longitude)/2.0f;
        double startDisNeighbor = self.startDisNeigh/2.0f;
        
        [self getPriceEstimateForStartLatitude:lat startLongitude:lon endLatitude:self.actualEnd.latitude endLongitude:self.actualEnd.longitude
                                       success:^(float lowEstimate, float highEstimate, float surgeMultiplier,
                                                 float lowPoolEstimate, float highPoolEstimate) {
                                           
                                           if ([self shouldUpdateX:lowEstimate highEstimate:highEstimate surgeMultiplier:surgeMultiplier dis:startDisNeighbor]) {
                                               self.bestDis = startDisNeighbor;
                                               self.bestLat = lat;
                                               self.bestLon = lon;
                                               self.bestLowEstimate = lowEstimate;
                                               self.bestHighEstimate = highEstimate;
                                               self.bestSurgeMultiplier = surgeMultiplier;
                                           }
                                           
                                           if ([self shouldUpdatePool:lowPoolEstimate highEstimate:highPoolEstimate surgeMultiplier:surgeMultiplier dis:startDisNeighbor]) {
                                               self.poolBestDis = startDisNeighbor;
                                               self.poolBestLat = lat;
                                               self.poolBestLon = lon;
                                               self.bestPoolLowEstimate = lowPoolEstimate;
                                               self.bestPoolHighEstimate = highPoolEstimate;
                                           }

                                           self.isDone = YES;
                                       } failure:^{
                                           self.isDone = YES;
                                       }];
    }
}

- (BOOL)canOpenDeepLinks {
    return ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"uber://"]]);
}

- (NSString *)urlForPickupLatitude:(double)pickupLatitude
                   pickupLongitude:(double)pickupLongitude
                      dropLatitude:(double)dropLatitude
                     dropLongitude:(double)dropLongitude
                           isUberX:(BOOL)isUberX {
    NSString *url = [NSString stringWithFormat:@"uber://?client_id=%@&action=setPickup&pickup[latitude]=%.4f&pickup[longitude]=%.4f&dropoff[latitude]=%.4f&dropoff[longitude]=%.4f", kUberClientID, pickupLatitude, pickupLongitude, dropLatitude, dropLongitude];
    return [NSString stringWithFormat:@"%@&product_id=%@", url, isUberX ? kUberXProductId:kUberPoolProductId];
}

@end
