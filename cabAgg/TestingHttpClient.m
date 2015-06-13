//
//  TestingHttpClient.m
//  cabAgg
//
//  Created by Kanav Arora on 6/13/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "TestingHttpClient.h"

@implementation TestingHttpClient

+ (TestingHttpClient *)sharedInstance {
    static TestingHttpClient *_sharedHTTPClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *baseUrl = @"https://cn-dc1.uber.com";
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
        [self.requestSerializer setValue:@"(+http://code.google.com/appengine; appid: APPID)" forHTTPHeaderField:@"User-Agent"];
    }
    
    return self;
}

- (void)test2 {
    NSDictionary *params = @{
                             @"version" : @"2.79.2",
                             @"language" : @"en",
                             @"vehicleViewId" : @(1491),
                             @"destination" : @{@"longitude" : @(-122.3925962), @"latitude" : @(37.7818412)},
                             @"pickupLocation" : @{@"longitude" : @(-122.4285589964091), @"latitude" : @(37.80085025039533), },
                             @"token" : @"33b4c98340a9d9413d7a08fd05ebc583",
                             @"appId" : @"com.ubercab.UberClient",
                             @"app" : @"client",
                             @"device": @"iphone",
                             @"messageType" : @"SetDestination",
                             @"performFareEstimate" : @(YES),
                             @"latitude" : @(37.8010110444264),
                             @"longitude" : @(-122.428524458842),
                             };
    [self POST:@"" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"fail");
    }];
}

- (void)test {
    NSDictionary *params = @{
                             @"version" : @"2.79.2",
        @"language" : @"en",
        @"vehicleViewId" : @(1491),
        @"destination" : @{@"longitude" : @(-122.3925962), @"latitude" : @(37.7818412)},
        @"pickupLocation" : @{@"longitude" : @(-122.4285589964091), @"latitude" : @(37.80085025039533), },
        @"token" : @"33b4c98340a9d9413d7a08fd05ebc583",
        @"appId" : @"com.ubercab.UberClient",
        @"app" : @"client",
        @"device": @"iphone",
        @"messageType" : @"SetDestination",
        @"performFareEstimate" : @(YES),
        @"latitude" : @(37.8010110444264),
        @"longitude" : @(-122.428524458842),
                             };
    [self POST:@"" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@", responseObject);

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"fail");
    }];
}

@end
