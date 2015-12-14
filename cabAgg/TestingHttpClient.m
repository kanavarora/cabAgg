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
        NSString *baseUrl = @"https://cn-dc1.uber.com/rt/riders/me/fare-estimate";
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
        NSDictionary *headerParams = @{@"User-Agent":@"client/iphone/2.107.3",
                                       @"x-uber-client-version":@"2.107.3",
                                       @"x-uber-token":@"19013496eadb6821a150d30590ac30f7",
                                       @"x-uber-client-name":@"client",
                                       @"x-uber-device-location-latitude": @"37.80102",
                                       @"x-uber-device-location-longitude": @"-122.42849",
                                       @"x-uber-device": @"iphone",
                                       @"x-uber-device-model": @"iPhone7,2",
                                       @"x-uber-device-os": @"9.1",
                                       @"x-uber-device-location-altitude": @"19.24258",
                                       @"x-uber-device-language": @"en_US",
                                       @"x-uber-device-id-tracking-enabled": @"1",
                                       @"Accept-Language": @"en-us",
                                       @"Connection": @"keep-alive",
                                       @"X-Uber-DCURL": @"https://cn-dc1.uber.com/",
                                       @"X-Uber-RedirectCount": @"0",
                                       @"x-uber-device-id": @"138151CD-A3F0-4A0B-892D-5BC3DDE62E9D",
                                       @"x-uber-device-epoch": @"1449751101324",
                                       @"Proxy-Connection": @"keep-alive",
                                       @"x-uber-client-id": @"com.ubercab.UberClient",
                                       @"x-uber-device-ids": @"aaid:9F063CB2-8F97-4611-ACB3-070222FA57A2",
                                       @"x-uber-device-h-accuracy": @"100.00000",
                                       @"x-uber-cloudkit-id": @"_647150546aa2be6d6a7c6cc48a372440",
                                       @"x-uber-device-v-accuracy": @"4.00000",
                                       };
        for (NSString *key in [headerParams allKeys]) {
            [self.requestSerializer setValue:headerParams[key] forHTTPHeaderField:key];
        }
    }
    
    return self;
}

- (void)test2 {
    NSDictionary *params = @{
                             @"capacity":@(1),
                             @"vehicleViewId" : @(1491),
                             @"destination" : @{@"longitude" : @(-122.3925962), @"latitude" : @(37.7818412)},
                             @"pickupLocation" : @{@"longitude" : @(-122.4285589964091), @"latitude" : @(37.80085025039533), },
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
