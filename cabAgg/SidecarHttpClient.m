//
//  SidecarHttpClient.m
//  cabAgg
//
//  Created by Kanav Arora on 1/8/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "SidecarHttpClient.h"

#define kSidecarPassword @"kanav574478"
#define kSidecarUsername @"9165212838"

@implementation SidecarHttpClient

+ (SidecarHttpClient *)sharedInstance {
    static SidecarHttpClient *_sharedSidecarHTTPClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSidecarHTTPClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"https://app.side.cr/"]];
    });
    
    return _sharedSidecarHTTPClient;
}
- (void)printCookies {
    NSURL *url = [NSURL URLWithString:@"https://app.side.cr/"];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    for (NSHTTPCookie *cookie in cookies)
    {
        NSLog(cookie.description);
    }
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
        [self.requestSerializer setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
        [self.requestSerializer setValue:@"app.side.cr" forHTTPHeaderField:@"Host"];
        [self.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [self.requestSerializer setValue:@"Sidecar/3.3.1 (iPhone; iOS 8.1.2; Scale/2.00)" forHTTPHeaderField:@"User-Agent"];
    }
    
    return self;
}

- (void)appLaunch {
    [self updateUser];
    /*
    [self printCookies];
   [self POST:@"login/appLaunch"
    parameters:@{@"username":@"9165212838", @"password":@"kanav574478",
                 @"deviceId":@"9F063CB2-8F97-4611-ACB3-070222FA57A2",
                 @"isForeground" :@"0",
                 @"userId":@"208478"}
       success:^(NSURLSessionDataTask *task, id responseObject) {
          // NSLog(responseObject);
           [self updateUser];
       } failure:^(NSURLSessionDataTask *task, NSError *error) {
           
       }];*/

}
- (void)updateUser {
    [self printCookies];
    NSDictionary *params = @{@"appVersion":	@"3.3.1",
                             @"bundleId":	@"cr.side.sidecar",
                             @"campaign": @"",
                             @"deviceId":	@"9F063CB2-8F97-4611-ACB3-070222FA57A2",
                             @"deviceModel":	@"Unknown iPhone",
                             @"deviceType":	@"0",
                             @"gpsAccuracy":	@"30",
                             @"lastUpdated":	@"1376018794",
                             @"lat":	@"37.80077062550727",
                             @"lng":	@"-122.4284160231449",
                             @"password":	@"kanav574478",
                             @"referrer": @"",
                             @"systemVersion":	@"8.1.2",
                             @"userId":	@"208478",
                             @"username":	@"9165212838"};
    [self POST:@"user/updateUserProfiling" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        [self performSelector:@selector(updateUserNotificationToken) withObject:self afterDelay:1.0f];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (void)updateUserNotificationToken {
    [self printCookies];
    NSDictionary *params = @{
                             @"notificationToken":	@"bf9b44a2f31f24a1ee9417c1761471e2fc7fea337bce90157474e59bb50c9695",
                             @"notificationType":	@"6",
                             @"password":	@"kanav574478",
                             @"username":	@"9165212838",
                             };
    [self POST:@"user/updateUserNotificationToken" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        [self getAccount];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}
- (void)getAccount {
    NSDictionary *params = @{@"password":	@"kanav574478",
                             @"username":	@"9165212838"};
    [self POST:@"account/getAccount" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (void)getForStart:(CLLocationCoordinate2D)start
                end:(CLLocationCoordinate2D)end
            success:(void (^)())successBlock {
    NSDictionary *params = @{@"username" :kSidecarUsername,
                             @"password" : kSidecarPassword,
                             @"pLat" : @(start.latitude),
                             @"pLng" : @(start.longitude),
                             @"dLat" : @(end.latitude),
                             @"dLng" : @(end.longitude),
                             @"listVisible" : @(1),
                             @"showTakenDrivers" : @(1)};
    
    
    [self POST:@"query/getBestMatch" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
}

@end
