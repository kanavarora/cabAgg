//
//  HTTPClient.m
//  cabAgg
//
//  Created by Kanav Arora on 1/14/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "AFHTTPSessionManager.h"

#import "HTTPClient.h"
#import "GlobalStateInterface.h"
#import <FBSDKCoreKit/FBSDKAppEvents.h>

#import <GoogleMaps/GoogleMaps.h>
#import "MainViewController.h"
#import "SPGooglePlacesPlaceDetailQuery.h"
#import "SPGooglePlacesAutocompleteUtilities.h"
#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocompletePlace.h"
#import "ShamelessPromotionViewController.h"
#import "AppConstants.h"
#import "NotificationManager.h"

@interface HTTPClient ()

@property (nonatomic, readwrite, assign) BOOL force;
@property (nonatomic, readwrite, strong) NSString *message;

@end

@implementation HTTPClient

+ (HTTPClient *)sharedInstance {
    static HTTPClient *_sharedHTTPClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if USE_TEST_SERVER
        NSString *baseUrl = @"http://localhost:8080/";
#elif USE_DEV_SERVER
        NSString *baseUrl = @"https://golden-context-82.appspot.com/";
#else
        NSString *baseUrl = @"https://golden-context-823.appspot.com/";
#endif        
        _sharedHTTPClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
    });
    
    return _sharedHTTPClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        NSMutableSet *acceptableContentTypes = [self.responseSerializer.acceptableContentTypes mutableCopy];
        [acceptableContentTypes addObject:@"text/html"];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithSet:acceptableContentTypes];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        [self.requestSerializer setValue:version forHTTPHeaderField:@"apiversion"];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(checkForUpdate)
                                                         name:UIApplicationWillEnterForegroundNotification
                                                       object:nil];
    }
    
    return self;
}

-(double)metersfromPlace:(CLLocationCoordinate2D)from andToPlace:(CLLocationCoordinate2D)to  {
    
    CLLocation *userloc = [[CLLocation alloc]initWithLatitude:from.latitude longitude:from.longitude];
    CLLocation *dest = [[CLLocation alloc]initWithLatitude:to.latitude longitude:to.longitude];
    
    CLLocationDistance dist = [userloc distanceFromLocation:dest];
    
    return dist;
    
}

- (void)getGeoCodeFor:(NSString *)address
        startLocation:(CLLocationCoordinate2D)startLocation
              success:(void (^)(NSArray *))successBlock {
    SPGooglePlacesAutocompleteQuery *query = [SPGooglePlacesAutocompleteQuery query];
    query.input = address;
    query.radius = 2000.0;
    query.language = @"en";
    //query.types = SPPlaceTypeGeocode; // Only return geocoding (address) results.
    query.location = startLocation;
    [query fetchPlaces:^(NSArray *places, NSError *error) {
        //for (SPGooglePlacesAutocompletePlace *place in places) {
         //   NSLog(@"%@", place.name);
        //}
        successBlock(places);
    }];
}

- (void)getGeoCodeFor3:(NSString *)address
        startLocation:(CLLocationCoordinate2D) startLocation
              success:(void (^)(NSArray *))successBlock {
    /*
    float swLat = startLocation.latitude - 1;
    float swLon = startLocation.longitude - 1;
    float neLat = startLocation.latitude + 1;
    float neLon = startLocation.longitude + 1;
    CLLocationCoordinate2D ne = CLLocationCoordinate2DMake(neLat, neLon);
    CLLocationCoordinate2D sw = CLLocationCoordinate2DMake(swLat, swLon);
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:ne
                                                                       coordinate:sw];
    [_placesClient autocompleteQuery:@"Sydney Oper"
                              bounds:bounds
                              filter:nil
                            callback:^(NSArray *results, NSError *error) {
                                if (error != nil) {
                                    NSLog(@"Autocomplete error %@", [error localizedDescription]);
                                    return;
                                }
                                
                                for (GMSAutocompletePrediction* result in results) {
                                    NSLog(@"Result '%@' with placeID %@", result.attributedFullText.string, result.placeID);
                                }
                            }];
     */
}

- (void)getGeoCodeFor2:(NSString *)address
        startLocation:(CLLocationCoordinate2D) startLocation
              success:(void (^)(NSArray *))successBlock {
    float swLat = startLocation.latitude - 1;
    float swLon = startLocation.longitude - 1;
    float neLat = startLocation.latitude + 1;
    float neLon = startLocation.longitude + 1;
    
    NSDictionary *params = @{@"address":address,
                             @"swLat": @(swLat),
                             @"swLon":@(swLon),
                             @"neLat":@(neLat),
                             @"neLon":@(neLon)};
    [self GET:@"api/v1/geocode" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *results = responseObject[@"results"];
        NSMutableArray *toSortResults = [NSMutableArray array];
        for (NSDictionary *result in results) {
            NSMutableDictionary *mutableResult = [result mutableCopy];
            float lat = [result[@"latitude"] floatValue];
            float lon = [result[@"longitude"] floatValue];
            double dis = [self metersfromPlace:startLocation andToPlace:CLLocationCoordinate2DMake(lat, lon)];
            mutableResult[@"dis"] = @(dis);
            [toSortResults addObject:mutableResult];
        }
        
        NSArray *finalResults = [toSortResults sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            double dis1 = [obj1[@"dis"] doubleValue];
            double dis2 = [obj2[@"dis"] doubleValue];
            if (dis1 < dis2) {
                return -1;
            } else if (dis2 < dis1) {
                return 1;
            } else {
                return 0;
            }
        }];
        
        if (successBlock)
            successBlock(finalResults);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"hurray");
    }];
}

/*
 Directions
 distanceMetres
 durationSecs
 */
- (void)getDirectionsFromStart:(CLLocationCoordinate2D)startLocation
                           end:(CLLocationCoordinate2D)endLocation
                       success:(void (^)(NSDictionary *))successBlock
                       failure:(void (^)())failureBlock {
    NSDictionary *params = @{@"startLat": @(startLocation.latitude),
                             @"startLon": @(startLocation.longitude),
                             @"endLat": @(endLocation.latitude),
                             @"endLon": @(endLocation.longitude)};
    [self GET:@"api/v1/directions" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if (responseObject[@"error"]) {
            if (failureBlock) failureBlock();
        } else {
            if (successBlock) successBlock(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failureBlock) failureBlock();
    }];
}

- (void)startApp {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSDictionary *params = @{@"udid": [[[UIDevice currentDevice] identifierForVendor] UUIDString],
                             @"version" : version,
                             @"localNotif?" :@(globalStateInterface.didStartFromNotif),
                             @"isNotifAllowed" : @([globalStateInterface.notificationManager checkIfNotifsEnabled])};
    
    [self POST:@"api/v1/start" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if (responseObject[@"error"]) {
            NSString *errorString = responseObject[@"error"][@"string"];
            if (!errorString) {
                return;
            }
            
            UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:@"Message"
                                                message:errorString
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                
                                     
                                 }];
            [alertController addAction:ok]; // add action to uialertcontroller
            
            [globalStateInterface.mainVC presentViewController:alertController animated:YES completion:nil];
        }
        if (responseObject[@"upgradeAvailable"]) {
            NSDictionary *data = responseObject[@"upgradeAvailable"];
            NSString *msg = data[@"message"];
            BOOL force = [data[@"force"] boolValue];
            self.force = force;
            self.message = msg;
            [self showUpdataDialog:msg force:force];
        } else {
            [self checkForShareDialog];
        }
        if (responseObject[@"optimizeDestination"]) {
            globalStateInterface.shouldOptimizeDestination = [responseObject[@"optimizeDestination"] boolValue];
        }
        if (responseObject[@"constants"]) {
            globalStateInterface.appConstants = [[AppConstants alloc] initWithDict:responseObject[@"constants"]];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // mhmmmm
        NSLog(@"failure");
    }];
    
    [FBSDKAppEvents logEvent:@"startup"];
    
}

- (void)checkForUpdate {
    if (self.force) {
        [self showUpdataDialog:self.message force:self.force];
    }
}

- (void)showUpdataDialog:(NSString *)message force:(BOOL)force {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Update available" message:message?message:@"Please download new update" preferredStyle:UIAlertControllerStyleAlert];
    if (!force) {
        UIAlertAction *nextTime = [UIAlertAction actionWithTitle:@"Next time" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }];
        [alertController addAction:nextTime];
    }
    UIAlertAction *updateAction = [UIAlertAction actionWithTitle:@"Upgrade" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *iTunesString = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@", kAppId];
        NSURL *iTunesURL = [NSURL URLWithString:iTunesString];
        [[UIApplication sharedApplication] openURL:iTunesURL];

    }];
    [alertController addAction:updateAction];
    [globalStateInterface.mainVC presentViewController:alertController animated:YES completion:nil];

}

- (void)trackWithEventName:(NSString *)eventName
           eventProperties:(NSDictionary *)eventProperties {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSDictionary *params = @{@"udid":udid,
                             @"version":version,
                             @"eventName":eventName,
                             @"eventProperties":eventProperties?eventProperties:@{}};
    [self POST:@"api/v1/track" parameters:params success:nil failure:nil];
}

- (void)showShamelessDialog:(int)level type:(ShamelessDialogType)type{
    ShamelessPromotionViewController *spVC = [[ShamelessPromotionViewController alloc] initWithType:type andLevel:level];
    spVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    spVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [globalStateInterface.mainVC presentViewController:spVC animated:YES completion:nil];
}

#define kNumForShamelessLevel1 3
#define kNumForShamelessLevel2 8
#define kNumForShamelessLevel3 22


#define kSavingsLevel1 5
#define kSavingsLevel2 20
#define kSavingsLevel3 50
- (void)checkForShareDialog {
    NSInteger total = [globalStateInterface numOptimizeTapped];
    NSInteger level = [globalStateInterface shamelessLevel];
    
    NSInteger savingsLevel = [globalStateInterface getSavingsLevel];
    float savings = globalStateInterface.savingsTillNow;
    if (savings > kSavingsLevel3 && savingsLevel < 3) {
        [self showShamelessDialog:2 type:ShamelessDialogTypeSavings];
        [globalStateInterface setSavingsLevel:3];
    } else if (savings > kSavingsLevel2 && savingsLevel < 2) {
        [self showShamelessDialog:1 type:ShamelessDialogTypeSavings];
        [globalStateInterface setSavingsLevel:2];
    } else if (savings > kSavingsLevel1 && savingsLevel < 1) {
        [self showShamelessDialog:0 type:ShamelessDialogTypeSavings];
        [globalStateInterface setSavingsLevel:1];
    }
    
    else if (total > kNumForShamelessLevel3 && level < 3) {
        [self showShamelessDialog:2 type:ShamelessDialogTypeUsage];
        [globalStateInterface increaseLevelShameless];
    } else if (total > kNumForShamelessLevel2 && level < 2) {
        [self showShamelessDialog:1 type:ShamelessDialogTypeUsage];
        [globalStateInterface increaseLevelShameless];
    } else if (total > kNumForShamelessLevel1 && level < 1) {
        [self showShamelessDialog:0 type:ShamelessDialogTypeUsage];
        [globalStateInterface increaseLevelShameless];
    }

}

@end
