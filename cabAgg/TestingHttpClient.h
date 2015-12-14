//
//  TestingHttpClient.h
//  cabAgg
//
//  Created by Kanav Arora on 6/13/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface TestingHttpClient : AFHTTPSessionManager
+ (TestingHttpClient *)sharedInstance;
- (void)test;
- (void)test2;

@end
