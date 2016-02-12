//
//  NotificationManager.h
//  cabAgg
//
//  Created by Kanav Arora on 2/12/16.
//  Copyright © 2016 LikwidSkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NotificationManager : NSObject

- (BOOL)checkIfNotifsEnabled;
- (void)registerForNotifications;

- (void)scheduleLocalNotif;

@end
