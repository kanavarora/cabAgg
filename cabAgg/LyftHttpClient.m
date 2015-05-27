//
//  LyftHttpClient.m
//  cabAgg
//
//  Created by Kanav Arora on 4/9/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "LyftHttpClient.h"

@implementation LyftHttpClient

+ (LyftHttpClient *)sharedInstance {
    static LyftHttpClient *_sharedHTTPClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *baseUrl = @"https://api.lyft.com/";
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

- (void)doPhoneAuth {
    [self POST:@"phoneauth" parameters:@{@"phone": @{@"number" : @"(916) 521-2838"}}  success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(error);
    }];
}

- (void)verifyPhone:(int)verification {
    [self POST:@"users" parameters:@{@"phone" : @{@"number" : @"(916) 521-2838",
                                                  @"verificationCode": @(verification)}}
       success:^(NSURLSessionDataTask *task, id responseObject) {
           NSLog(responseObject);
       } failure:^(NSURLSessionDataTask *task, NSError *error) {
           NSLog(error);
       }];
}


@end
