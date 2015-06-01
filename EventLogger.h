//
//  EventLogger.h
//  cabAgg
//
//  Created by Kanav Arora on 5/31/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventLogger : NSObject

- (void)trackEventName:(NSString *)eventName
            properties:(NSDictionary *)props;

@end
