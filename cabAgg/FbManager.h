//
//  FbManager.h
//  cabAgg
//
//  Created by Kanav Arora on 7/27/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface FbManager : NSObject

+ (void)shareToFb;
+ (void)shareToTwitter:(NSString *)tweet;
+ (MFMessageComposeViewController *)shareToText;

@end
