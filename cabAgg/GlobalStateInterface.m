//
//  GlobalStateInterface.m
//  cabAgg
//
//  Created by Kanav Arora on 1/14/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "GlobalStateInterface.h"

#import <MapKit/MapKit.h>

#import "EventLogger.h"
#import "NotificationManager.h"

GlobalStateInterface *globalStateInterface;

@implementation GlobalStateInterface

- (id)init {
    if (self = [super init]) {
        _eventLogger = [[EventLogger alloc] init];
        _notificationManager = [[NotificationManager alloc] init];
    }
    return self;
}

#define fequal(a,b) (fabs((a) - (b)) < 0.00001)

+ (BOOL)areEqualLocations:(CLLocationCoordinate2D)loc1 andloc2:(CLLocationCoordinate2D)loc2 {
    return fequal(loc1.latitude, loc2.latitude) && fequal(loc1.longitude, loc2.longitude);
}

#define kKeyNumOptimize @"numOptimize"
#define kKeyShamelessLevel @"shamelessLevel"
#define kKeySavingsAmount @"savingsAmount"
#define kKeySavingsLevel @"savingsLevel"
- (void)increaseNumOptimize {
    NSInteger i = [[NSUserDefaults standardUserDefaults] integerForKey:kKeyNumOptimize];
    [[NSUserDefaults standardUserDefaults] setInteger:i+1 forKey:kKeyNumOptimize];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)numOptimizeTapped {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kKeyNumOptimize];
}

- (void)increaseLevelShameless {
    NSInteger i = [[NSUserDefaults standardUserDefaults] integerForKey:kKeyShamelessLevel];
    [[NSUserDefaults standardUserDefaults] setInteger:i+1 forKey:kKeyShamelessLevel];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)shamelessLevel {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kKeyShamelessLevel];
}

- (void)increasingSavingsBy:(float)savings {
    float i = [[NSUserDefaults standardUserDefaults] floatForKey:kKeySavingsAmount];
    [[NSUserDefaults standardUserDefaults] setFloat:i+savings forKey:kKeySavingsAmount];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (float)savingsTillNow {
    return [[NSUserDefaults standardUserDefaults] floatForKey:kKeySavingsAmount];
}

- (void)setSavingsLevel:(NSInteger)level {
    [[NSUserDefaults standardUserDefaults] setInteger:level forKey:kKeySavingsLevel];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)getSavingsLevel {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kKeySavingsLevel];
}

- (UIViewController *)topController {
    UIViewController *activeController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([activeController isKindOfClass:[UINavigationController class]]) {
        activeController = [(UINavigationController*) activeController visibleViewController];
    }
    return activeController;
}
@end