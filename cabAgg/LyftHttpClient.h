//
//  LyftHttpClient.h
//  cabAgg
//
//  Created by Kanav Arora on 4/9/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@interface LyftHttpClient : AFHTTPSessionManager

+ (LyftHttpClient *)sharedInstance;
- (void)doPhoneAuth;
- (void)verifyPhone:(int)verification;

@end
