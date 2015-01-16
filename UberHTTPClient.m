//
//  UberHTTPClient.m
//  cabAgg
//
//  Created by Kanav Arora on 1/7/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "UberHTTPClient.h"

@interface UberHTTPClient ()

@property (nonatomic, readwrite, assign) int numRequests; // to keep track what id of bulk request we doing
@end


@implementation UberHTTPClient

#define kUberApiKey @"EgQAboNipnPTvctxRzqNBmC_oHcdoDeP7UQ1MCYN"
#define kUberClientID @"lHpulRd2-QygzWuKtYPjS2s-QU4N-YyU"
#define kUberXProductId @"a1111c8c-c720-46c3-8534-2fcdd730040d"
#define kUberPoolProductId @"26546650-e557-4a7b-86e7-6a3942445247"

/// Rate limit of 1000 requests an hour

+ (UberHTTPClient *)sharedInstance {
    static UberHTTPClient *_sharedUberHTTPClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUberHTTPClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.uber.com/"]];
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

- (void)getPriceEstimateForStartLatitude:(float)startLatitude
                           startLongitude:(float)startLongitude
                             endLatitude:(float)endLatitude
                            endLongitude:(float)endLongitude
                                 success:(void (^)(float, float, float))successBlock {
    NSDictionary *params = @{@"server_token" : kUberApiKey,
                             @"start_latitude" : @(startLatitude),
                             @"start_longitude" : @(startLongitude),
                             @"end_latitude" : @(endLatitude),
                             @"end_longitude" : @(endLongitude)};
    [self GET:@"v1/estimates/price" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *products = responseObject[@"prices"];
        for (NSDictionary *product in products) {
            if ([product[@"display_name"] isEqualToString:@"uberX"]) {
                float lowEstimate = [product[@"low_estimate"] floatValue];
                float highEstimate = [product[@"high_estimate"] floatValue];
                float surgeMultiplier = [product[@"surge_multiplier"] floatValue];
                successBlock(lowEstimate, highEstimate, surgeMultiplier);
                break;
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];

}

- (void)getPriceEstimatesForStart:(CLLocationCoordinate2D)start
                              end:(CLLocationCoordinate2D)end
                 startDisNeighbor:(float)startDisNeighbor {
    self.actualEnd = end;
    self.actualStart = start;
    self.numRequests++;
    self.bestI = -1;
    self.bestJ = -1;
    self.bestLowEstimate = 100000.0f;
    self.bestHighEstimate = 1000000.0f;
    self.bestSurgeMultiplier = 100.0f;
    
    float metersPerLat = 111111.0f;
    float metersPerLon = 111111* cosf(start.latitude);
    
    float latDegNeigh = startDisNeighbor/metersPerLat;
    float lonDegNeigh = startDisNeighbor/metersPerLon;
    
    BOOL calculateStart = startDisNeighbor > 40.0f;
    
    int currentRequest = self.numRequests;
    
    for (int i=(calculateStart?-1:0); i<=(calculateStart?1:0); i++) {
        for (int j=(calculateStart?-1:0); j<=(calculateStart?1:0); j++) {
            
            float lat = start.latitude + (i*latDegNeigh);
            float lon = start.longitude + (j*lonDegNeigh);
            
            if (abs(i*j) == 1) {
                lat = start.latitude + (i* sqrt(0.5) * latDegNeigh);
                lon = start.longitude + (j*sqrt(0.5) * lonDegNeigh);
            }
            
            [self getPriceEstimateForStartLatitude:lat startLongitude:lon endLatitude:end.latitude endLongitude:end.longitude success:^(float lowEstimate, float highEstimate, float surgeMultiplier) {
                if (currentRequest != self.numRequests)
                    return;
                
                if (i==0 && j==0) {
                    self.actualHighEstimate = highEstimate;
                    self.actualLowEstimate = lowEstimate;
                    self.actualSurgeMultiplier = surgeMultiplier;
                }
                
                if (surgeMultiplier < self.bestSurgeMultiplier ||
                    ((surgeMultiplier == self.bestSurgeMultiplier) && (i==0 && j==0))) {
                    self.bestSurgeMultiplier = surgeMultiplier;
                    self.bestLowEstimate = lowEstimate;
                    self.bestHighEstimate = highEstimate;
                    self.bestLat = lat;
                    self.bestLon = lon;
                }
                
            }];
        }
    }
}

- (BOOL)canOpenDeepLinks {
    return ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"uber://"]]);
}

- (NSString *)urlForPickupLatitude:(float)pickupLatitude
                   pickupLongitude:(float)pickupLongitude
                      dropLatitude:(float)dropLatitude
                     dropLongitude:(float)dropLongitude
                           isUberX:(BOOL)isUberX {
    BOOL canOpen = ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"uber://"]]);
    if (!canOpen) {
        return nil;
    }
    NSString *url = [NSString stringWithFormat:@"uber://?client_id=%@&action=setPickup&pickup[latitude]=%.4f&pickup[longitude]=%.4f&dropoff[latitude]=%.4f&dropoff[longitude]=%.4f", kUberClientID, pickupLatitude, pickupLongitude, dropLatitude, dropLongitude];
    return [NSString stringWithFormat:@"%@&product_id=%@", url, isUberX ? kUberXProductId:kUberPoolProductId];
}

@end
