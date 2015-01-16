//
//  HTTPClient.m
//  cabAgg
//
//  Created by Kanav Arora on 1/14/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "AFHTTPSessionManager.h"

#import "HTTPClient.h"


@implementation HTTPClient

+ (HTTPClient *)sharedInstance {
    static HTTPClient *_sharedHTTPClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if USE_TEST_SERVER
        NSString *baseUrl = @"http://localhost:8080/";
#else
        NSString *baseUrl = @"http://golden-context-823.appspot.com/";
#endif        
        _sharedHTTPClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
    });
    
    return _sharedHTTPClient;
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

-(double)metersfromPlace:(CLLocationCoordinate2D)from andToPlace:(CLLocationCoordinate2D)to  {
    
    CLLocation *userloc = [[CLLocation alloc]initWithLatitude:from.latitude longitude:from.longitude];
    CLLocation *dest = [[CLLocation alloc]initWithLatitude:to.latitude longitude:to.longitude];
    
    CLLocationDistance dist = [userloc distanceFromLocation:dest];
    
    return dist;
    
}

- (void)getGeoCodeFor:(NSString *)address
        startLocation:(CLLocationCoordinate2D) startLocation
              success:(void (^)(NSArray *))successBlock {
    float swLat = startLocation.latitude - 1;
    float swLon = startLocation.longitude - 1;
    float neLat = startLocation.latitude + 1;
    float neLon = startLocation.longitude + 1;
    
    NSDictionary *params = @{@"address":address,
                             @"swLat": @(swLat),
                             @"swLon":@(swLon),
                             @"neLat":@(neLat),
                             @"neLon":@(neLon)};
    [self GET:@"geocode" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *results = responseObject[@"results"];
        NSMutableArray *toSortResults = [NSMutableArray array];
        for (NSDictionary *result in results) {
            NSMutableDictionary *mutableResult = [result mutableCopy];
            float lat = [result[@"latitude"] floatValue];
            float lon = [result[@"longitude"] floatValue];
            double dis = [self metersfromPlace:startLocation andToPlace:CLLocationCoordinate2DMake(lat, lon)];
            mutableResult[@"dis"] = @(dis);
            [toSortResults addObject:mutableResult];
        }
        
        NSArray *finalResults = [toSortResults sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            double dis1 = [obj1[@"dis"] doubleValue];
            double dis2 = [obj2[@"dis"] doubleValue];
            if (dis1 < dis2) {
                return -1;
            } else if (dis2 < dis1) {
                return 1;
            } else {
                return 0;
            }
        }];
        
        if (successBlock)
            successBlock(finalResults);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"hurray");
    }];
}

@end
