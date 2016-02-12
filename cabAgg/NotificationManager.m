//
//  NotificationManager.m
//  cabAgg
//
//  Created by Kanav Arora on 2/12/16.
//  Copyright © 2016 LikwidSkin. All rights reserved.
//

#import "NotificationManager.h"

#import "GlobalStateInterface.h"

@implementation NotificationManager

- (BOOL)checkIfNotifsEnabled {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]){ // Check it's iOS 8 and above
        UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        
        if (grantedSettings.types == UIUserNotificationTypeNone) {
            return NO;
        }
        else if (grantedSettings.types & UIUserNotificationTypeSound & UIUserNotificationTypeAlert ){
            return YES;
        }
        else if (grantedSettings.types  & UIUserNotificationTypeAlert){
            return YES;
        }
    }
    return NO;
}

- (void)registerForNotifications {
    if ([self checkIfNotifsEnabled]) {
        return;
    }
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
}

- (void)cancelLocalNotifs {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)scheduleLocalNotif {
    [self cancelLocalNotifs];
    
    if (![globalStateInterface.appConstants getBoolForKey:@"isLocalNotifEnabled"]) {
        return;
    }
    NSCalendar *gregCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponent = [gregCalendar components:NSCalendarUnitYear  | NSCalendarUnitWeekOfYear fromDate:[NSDate date]];
    
    NSInteger day = [globalStateInterface.appConstants getIntForKey:@"weekendNotifDay"];
    NSInteger hour = [globalStateInterface.appConstants getIntForKey:@"weekendNotifHour"];
    NSInteger minute = [globalStateInterface.appConstants getIntForKey:@"weekendNotifMinute"];
    [dateComponent setWeekday:day > 0 ? day : 6];
    [dateComponent setHour: hour > 0 ? hour : 21];
    [dateComponent setMinute:minute];
    
    NSDate *fireDate = [gregCalendar dateFromComponents:dateComponent];

    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = fireDate;
    NSString *alertText = [globalStateInterface.appConstants getStrForKey:@"weekendNotifText"];
    localNotification.alertBody = alertText ? alertText : @"Weekend is here! Trust cabalot to save you on cab rides!";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.repeatInterval = NSCalendarUnitWeekOfYear;
    localNotification.applicationIconBadgeNumber = 1;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
