//
//  GlobalStateInterface.h
//  cabAgg
//
//  Created by Kanav Arora on 1/14/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class  MainViewController;
@class EventLogger;
@interface GlobalStateInterface : NSObject

@property (nonatomic, readwrite, weak) MainViewController *mainVC;
@property (nonatomic, readwrite, assign) BOOL shouldOptimizeDestination;
@property (nonatomic, readwrite, strong) EventLogger *eventLogger;

+ (BOOL)areEqualLocations:(CLLocationCoordinate2D)loc1
                  andloc2:(CLLocationCoordinate2D)loc2;

- (void)increaseNumOptimize;
- (NSInteger)numOptimizeTapped;
- (NSInteger)shamelessLevel;
- (void)increaseLevelShameless;
- (void)increasingSavingsBy:(float)savings;
- (float)savingsTillNow;
- (void)setSavingsLevel:(NSInteger)level;
- (NSInteger)getSavingsLevel;
- (UIViewController *)topController;

@end

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#define USE_TEST_SERVER 1

#define USE_DEV_SERVER 0

#define kAppId @"976028424"

/*
 *  System Versioning Preprocessor Macros
 */

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


extern GlobalStateInterface *globalStateInterface;