//
//  AppDelegate.m
//  cabAgg
//
//  Created by Kanav Arora on 1/4/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import <GoogleMaps/GoogleMaps.h>
#define MR_SHORTHAND
#import "CoreData+MagicalRecord.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "SidecarHttpClient.h"
#import "MainViewController.h"
#import "GlobalStateInterface.h"
#import "iRate.h"
#import "NotificationManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (void)initialize
{
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 5;
    [iRate sharedInstance].usesUntilPrompt = 10;
    //[iRate sharedInstance].previewMode = YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //[[UILabel appearance] setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:8.0]];
    [GMSServices provideAPIKey:@"AIzaSyBpBOn34TqmbnLTRCpVnB1ELbIXbxLOGLg"];
    [Fabric with:@[CrashlyticsKit]];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    MainViewController *mainVC = [[MainViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:mainVC];
    // Set loginUIViewController as root view controller
    [[self window] setRootViewController:navVC];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    globalStateInterface = [[GlobalStateInterface alloc] init];
    globalStateInterface.mainVC = mainVC;
    
    [self setAppearance];
    [MagicalRecord setupCoreDataStack];
    //[MagicalRecord setupCoreDataStackWithStoreNamed:@"CabAgg"];
    
    // handle local notification launch
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        globalStateInterface.didStartFromNotif = YES;
    }
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
    
    return YES;
}

- (void)setAppearance {
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    //[[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor blackColor], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [globalStateInterface.notificationManager scheduleLocalNotif];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    CLLocationCoordinate2D center = [globalStateInterface.mainVC centerOfMap];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    float lat = center.latitude;
    float lng = center.longitude;
    if (lat !=0 && lng != 0) {
        [userDefaults setFloat:lat forKey:@"startLat"];
        [userDefaults setFloat:lng forKey:@"startLng"];
        [userDefaults synchronize];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder"
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}
@end
