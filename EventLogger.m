//
//  EventLogger.m
//  cabAgg
//
//  Created by Kanav Arora on 5/31/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "EventLogger.h"
#import "HTTPClient.h"
@implementation EventLogger


- (void)trackEventName:(NSString *)eventName
            properties:(NSDictionary *)props {
    [[HTTPClient sharedInstance] trackWithEventName:eventName eventProperties:props];
}
@end
