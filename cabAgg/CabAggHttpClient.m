//
//  CabAggHttpClient.m
//  cabAgg
//
//  Created by Kanav Arora on 1/4/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "CabAggHttpClient.h"
#import "AFHTTPRequestOperationManager.h"
#import "GlobalStateInterface.h"
#import "HTTPClient.h"
#import "MainViewController.h"
#import "EventLogger.h"

@interface CabAggHttpClient ()


@property (nonatomic, readwrite, assign) double startDisNeigh;
@property (nonatomic, readwrite, assign) double endDisNeigh;

@property (nonatomic, readwrite, assign) double bestStartDisNeigh;
@property (nonatomic, readwrite, assign) double bestEndDisNeigh;

@property (nonatomic, readwrite, assign) double lyftBestStartDisNeigh;

@property (nonatomic, readwrite, assign) int numStartRequests;
@property (nonatomic, readwrite, assign) int numEndRequests;

@property (nonatomic, readwrite, strong) NSArray *hotspotLocations;

@property (nonatomic, readwrite, assign) BOOL isDone;

@property (nonatomic, readwrite, assign) BOOL hasShownError;

@property (nonatomic, readwrite, strong) AFHTTPRequestOperationManager *manager;
@end

#define kMilesForADollar 0.2
#define METERS_PER_MILE 1609.344
#define kMetresForADollar (kMilesForADollar * METERS_PER_MILE)

@implementation CabAggHttpClient

- (id)init {
    if (self = [super init]) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        [manager.requestSerializer setValue:version forHTTPHeaderField:@"apiversion"];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.manager = manager;
    }
    return self;
}

+ (NSString *)deepLinkUrl {
    NSString *url = [NSString stringWithFormat:@"lyft://"];
    return url;
}

+ (NSString *)urlForPickupLatitude:(double)pickupLatitude
                   pickupLongitude:(double)pickupLongitude
                      dropLatitude:(double)dropLatitude
                     dropLongitude:(double)dropLongitude
                        isLyftLine:(BOOL)isLyftLine {
    NSString *url = [NSString stringWithFormat:@"lyft://ridetype?id=%@&pickup[latitude]=%.4f&pickup[longitude]=%.4f&destination[latitude]=%.4f&destination[longitude]=%.4f", isLyftLine ? @"lyft_line" : @"lyft", pickupLatitude, pickupLongitude, dropLatitude, dropLongitude];
    return url;
}

- (NSDictionary *)markerForLocation:(CLLocationCoordinate2D)loc {
    return @{@"lat" : @(loc.latitude),
             @"lng" : @(loc.longitude)};
}

- (NSDictionary *)markerForLatitude:(double)latitude
                          longitude:(double)longitude {
    return @{@"lat" : @(latitude),
             @"lng" : @(longitude)};
}

- (CLLocationCoordinate2D)locationForMarker:(NSDictionary *)locDict {
    return CLLocationCoordinate2DMake([locDict[@"lat"] floatValue], [locDict[@"lng"] floatValue]);
}

- (void)showErrorIfNeeded:(int)errorCode {
    if (!self.hasShownError) {
        self.hasShownError = YES;
        if (errorCode == 1) {
            UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:@"Cabalot is busy right now."
                                                message:@"Cabalot is pretty popular right now. We are working to meet our increasing popularity. For now, please try later."
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     //Do some thing here
                                     [alertController dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
            [alertController addAction:ok]; // add action to uialertcontroller
            
            [globalStateInterface.mainVC presentViewController:alertController animated:YES completion:nil];
        }
    }
}

/*
 Pricing -
 dynamicPricing
 minimum
 perMile
 perMinute
 pickup
 */

- (NSArray *)parseHotspots:(NSArray *)hotspotDicts {
    NSMutableArray *toRtn = [NSMutableArray array];
    for (NSDictionary *hotspotDict in hotspotDicts) {
        if (hotspotDict[@"lat"] && hotspotDict[@"lng"]) {
            double lat = [hotspotDict[@"lat"] doubleValue];
            double lng = [hotspotDict[@"lng"] doubleValue];
            CLLocation *loc = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
            [toRtn addObject:loc];
        }
    }
    return toRtn;
}

- (void)getInfoForMarker:(NSDictionary *)marker
           andDestMarker:(NSDictionary *)destMarker
            successBlock:(void (^)(float, BOOL, NSDictionary *, NSDictionary *, NSArray *))successBlock
            failureBlock:(void (^)())failureBlock
{
    NSDictionary *params = @{@"startLat" : marker[@"lat"],
                             @"startLon" : marker[@"lng"],
                             @"endLat" : destMarker[@"lat"],
                             @"endLon" : destMarker[@"lng"],
                             @"bestDynPricing" : (self.lyftBestPrice[@"dynamicPricing"] ? self.lyftBestPrice[@"dynamicPricing"] : @(0.0f)),
                             };
#if USE_TEST_SERVER
    NSString *baseUrl = @"http://localhost:8080/api/v1/lyft";
#elif USE_DEV_SERVER
    NSString *baseUrl = @"https://golden-context-82.appspot.com/api/v1/lyft";
#else
    NSString *baseUrl = @"https://golden-context-823.appspot.com/api/v1/lyft";
#endif
    
    [self.manager GET:baseUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject[@"error"]) {
            NSDictionary *errorDict = responseObject[@"error"];
            int errorCode = [errorDict[@"code"] intValue];
            [self showErrorIfNeeded:errorCode];
            failureBlock();
        } else {
            NSDictionary *directions = responseObject[@"directions"];
            if (directions[@"error"]) {
                directions = nil;
            }
            BOOL isLyftLineRouteValid = [responseObject[@"isLyftLineRouteValid"] boolValue];
            
            NSArray *hotspots = [self parseHotspots:responseObject[@"hotspotLocations"]];
            
            successBlock([responseObject[@"price"] floatValue]/100.0,
                         isLyftLineRouteValid,
                         responseObject[@"standardRide"],
                         directions,
                         hotspots);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock();
    }];
}

- (BOOL)isBetterDealPrice1:(float)price1
                 distance1:(float)distance1
                    price2:(float)price2
                 distance2:(float)distance2 {
    float discount1 = self.actPrice - price1;
    float discount2 = self.actPrice - price2;
    float normalizedDiscount1 = distance1==0.0f? 0 : (discount1/distance1);
    float normalizedDiscount2 = distance2==0.0f? 0 : (discount2/distance2);
    normalizedDiscount1 = MAX(normalizedDiscount1, 1.0f/kMetresForADollar);
    normalizedDiscount2 = MAX(normalizedDiscount2, 1.0f/kMetresForADollar);
    
    if (normalizedDiscount2 > normalizedDiscount1) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isBetterDealPrice:(float)price
                 distance:(float)distance {
    return [self isBetterDealPrice1:self.bestPrice
                          distance1:(self.bestStartDisNeigh+self.bestEndDisNeigh)
                             price2:price distance2:distance];
}

- (BOOL)isBetterLyftDeal:(NSDictionary *)price1
             directions1:(NSDictionary *)directions1
               disNeigh1:(double)disNeigh1
                  price2:(NSDictionary *)price2
             directions2:(NSDictionary *)directions2
               disNeigh2:(double)disNeigh2 {
    float lyftPrice1 = [self getStandardPriceForDirections:directions1 pricing:price1];
    float lyftPrice2 = [self getStandardPriceForDirections:directions2 pricing:price2];
    float dynPricing1 = price1[@"dynamicPricing"] ? [price1[@"dynamicPricing"] floatValue] : 0.0f;
    float dynPricing2 = price2[@"dynamicPricing"] ? [price2[@"dynamicPricing"] floatValue] : 0.0f;
    
    if (disNeigh1 < disNeigh2) {
        return dynPricing2 < dynPricing1;
    } else if (disNeigh2 < disNeigh1) {
        return dynPricing2 <= dynPricing1;
    } else {
        return lyftPrice2 < lyftPrice1;
    }
}

- (void)optimizeForStart:(CLLocationCoordinate2D)start
                     end:(CLLocationCoordinate2D)end
        startDisNeighbor:(float)startDisNeighbor
          endDisNeighbor:(float)endDisNeighbor {
    self.start = start;
    self.end = end;
    self.startDisNeigh = startDisNeighbor;
    self.endDisNeigh = endDisNeighbor;
    
    self.actPrice = -1.0f;
    self.bestPrice = -1.0f;
    self.bestLon = start.longitude;
    self.bestLat = start.latitude;
    self.bestEndLon = end.longitude;
    self.bestEndLat = end.latitude;

    self.lyftActPrice = self.lyftBestPrice = nil;
    self.lyftBestLat = start.latitude;
    self.lyftBestLon = start.longitude;
    self.bestStartDisNeigh = self.bestEndDisNeigh = 0.0f;
    
    self.lyftActDirections = self.lyftBestDirections = nil;
    self.isLyftLineRouteValid = YES;
    self.isLyftLRouteValid = YES;
    self.hasShownError = NO;
    
    [self getActual];
}

- (void)getActual {
    [self getInfoForMarker:[self markerForLocation:self.start]
             andDestMarker:[self markerForLocation:self.end]
              successBlock:^(float price,
                             BOOL isLyftLineValid,
                             NSDictionary *standardPricing,
                             NSDictionary *directions,
                             NSArray *hotspots) {
                  self.isLyftLineRouteValid = isLyftLineValid;
                  self.isLyftLRouteValid = ([standardPricing[@"lyftPrice"] floatValue] > 0);
                  self.actPrice = price;
                  self.bestPrice = price;
                  self.lyftActDirections = directions;
                  self.lyftBestDirections = directions;
                  self.lyftActPrice = standardPricing;
                  self.lyftBestPrice = standardPricing;
                  self.lyftBestStartDisNeigh = 0.0f;
                  self.hotspotLocations = hotspots;
                  if (!self.isLyftLRouteValid  && !self.isLyftLineRouteValid) {
                      self.isDone = YES;
                  } else {
                      [self optimizeForStart];
                  }
              }
              failureBlock:^{
                  self.isDone = YES;
              }];
}

- (void)optimizeForStart {
    if (self.startDisNeigh < 40.0f) {
        [self optimizeForEnd];
        return;
    }
    
    double startDisNeighbor = self.startDisNeigh;
    double metersPerLat = 111111.0;
    double metersPerLon = 111111* cosf(self.start.latitude);
    
    double latDegNeigh = startDisNeighbor/metersPerLat;
    double lonDegNeigh = startDisNeighbor/metersPerLon;
    
    for (int i=-1; i<=1 ; i++) {
        for (int j=-1; j<=1 ; j++) {
            
            if (i==0 && j== 0) {
                continue;
            }
            
            double lat = self.start.latitude + (i*latDegNeigh);
            double lon = self.start.longitude + (j*lonDegNeigh);
            
            if (abs(i*j) == 1) {
                lat = self.start.latitude + (i* sqrt(0.5) * latDegNeigh);
                lon = self.start.longitude + (j*sqrt(0.5) * lonDegNeigh);
            }
            
            double endLat = self.end.latitude;
            double endLon = self.end.longitude;
            
            NSDictionary *startMarker = [self markerForLatitude:lat longitude:lon];
            NSDictionary *endMarker = [self markerForLatitude:endLat longitude:endLon];
            
            [self getInfoForMarker:startMarker andDestMarker:endMarker successBlock:^(float dollars, BOOL isLyftLineValid, NSDictionary *standardPricing, NSDictionary *directions, NSArray *hotspots) {
                
                self.numStartRequests++;
                
                if (dollars > 0 && [self isBetterDealPrice:dollars distance:startDisNeighbor]) {
                    self.bestPrice = dollars;
                    self.bestStartDisNeigh = startDisNeighbor;
                    self.bestLat = lat;
                    self.bestLon = lon;
                }
                
                if ([self isBetterLyftDeal:self.lyftBestPrice
                               directions1:self.lyftBestDirections
                                 disNeigh1:self.lyftBestStartDisNeigh
                                    price2:standardPricing
                               directions2:directions
                                 disNeigh2:startDisNeighbor]) {
                    self.lyftBestDirections = directions;
                    self.lyftBestPrice = standardPricing;
                    self.lyftBestLat = lat;
                    self.lyftBestLon = lon;
                    self.lyftBestStartDisNeigh = startDisNeighbor;
                }
                
                [self checkToOptimizeForStart];
            } failureBlock:^{
                self.numStartRequests++;
                
                [self checkToOptimizeForStart];
            }];
        }
    }
}

- (void)checkToOptimizeForStart {
    if (self.numStartRequests == 8) {
        [self furtherOptimizeStartForLyftLine];
    }
}

- (void)furtherOptimizeStartForLyftLine {
    CLLocationCoordinate2D bestLyftLineStart = CLLocationCoordinate2DMake(self.bestLat, self.bestLon);
    if ([GlobalStateInterface areEqualLocations:bestLyftLineStart andloc2:self.start]) {
        [self furtherOptimizeStartForLyft];
    } else {
        float lat = (self.bestLat + self.start.latitude)/2.0f;
        float lon = (self.bestLon + self.start.longitude)/2.0f;
        
        float startDisNeighbor = self.bestStartDisNeigh/2.0f;
        NSDictionary *startMarker = [self markerForLatitude:lat longitude:lon];
        NSDictionary *endMarker = [self markerForLatitude:self.end.latitude longitude:self.end.longitude];
        
        [self getInfoForMarker:startMarker andDestMarker:endMarker successBlock:^(float dollars, BOOL isLyftLineValid, NSDictionary *standardPricing, NSDictionary *directions, NSArray *hotspots) {
            
            if (dollars > 0 && [self isBetterDealPrice:dollars distance:startDisNeighbor]) {
                self.bestPrice = dollars;
                self.bestStartDisNeigh = startDisNeighbor;
                self.bestLat = lat;
                self.bestLon = lon;
            }
            
            if ([self isBetterLyftDeal:self.lyftBestPrice
                           directions1:self.lyftBestDirections
                             disNeigh1:self.lyftBestStartDisNeigh
                                price2:standardPricing
                           directions2:directions
                             disNeigh2:startDisNeighbor]) {
                self.lyftBestDirections = directions;
                self.lyftBestPrice = standardPricing;
                self.lyftBestLat = lat;
                self.lyftBestLon = lon;
                self.lyftBestStartDisNeigh = startDisNeighbor;
            }
            
            [self furtherOptimizeStartForLyft];
        } failureBlock:^{
            [self furtherOptimizeStartForLyft];
        }];

    }
    
}

- (void)furtherOptimizeStartForLyft {
    CLLocationCoordinate2D bestLyftStart = CLLocationCoordinate2DMake(self.lyftBestLat, self.lyftBestLon);
    if ([GlobalStateInterface areEqualLocations:bestLyftStart andloc2:self.start]) {
        [self optimizeForHotspots];
    } else {
        float lat = (self.lyftBestLat + self.start.latitude)/2.0f;
        float lon = (self.lyftBestLon + self.start.longitude)/2.0f;
        
        float startDisNeighbor = self.lyftBestStartDisNeigh/2.0f;
        NSDictionary *startMarker = [self markerForLatitude:lat longitude:lon];
        NSDictionary *endMarker = [self markerForLatitude:self.end.latitude longitude:self.end.longitude];
        
        [self getInfoForMarker:startMarker andDestMarker:endMarker successBlock:^(float dollars, BOOL isLyftLineValid, NSDictionary *standardPricing, NSDictionary *directions, NSArray *hotspots) {
            
            if (dollars > 0 && [self isBetterDealPrice:dollars distance:startDisNeighbor]) {
                self.bestPrice = dollars;
                self.bestStartDisNeigh = startDisNeighbor;
                self.bestLat = lat;
                self.bestLon = lon;
            }
            
            if ([self isBetterLyftDeal:self.lyftBestPrice
                           directions1:self.lyftBestDirections
                             disNeigh1:self.lyftBestStartDisNeigh
                                price2:standardPricing
                           directions2:directions
                             disNeigh2:startDisNeighbor]) {
                self.lyftBestDirections = directions;
                self.lyftBestPrice = standardPricing;
                self.lyftBestLat = lat;
                self.lyftBestLon = lon;
                self.lyftBestStartDisNeigh = startDisNeighbor;
            }
            
            [self optimizeForHotspots];
        } failureBlock:^{
            [self optimizeForHotspots];
        }];

    }
}

- (void)optimizeForHotspots {
    CLLocation *startLoc = [[CLLocation alloc] initWithLatitude:self.start.latitude longitude:self.start.longitude];
    double bestDist = 10000000;
    CLLocation *closestHotspot = nil;
    for (CLLocation *loc in self.hotspotLocations) {
        double currDist = [startLoc distanceFromLocation:loc];
        if (currDist < bestDist) {
            bestDist = currDist;
            closestHotspot = loc;
        }
    }
    
    if (!closestHotspot) {
        return [self optimizeForEnd];
    }
    
    float startDisNeighbor = bestDist;
    float lat = closestHotspot.coordinate.latitude;
    float lon = closestHotspot.coordinate.longitude;
    
    NSDictionary *startMarker = [self markerForLatitude:lat longitude:lon];
    NSDictionary *endMarker = [self markerForLatitude:self.end.latitude longitude:self.end.longitude];
    
    [self getInfoForMarker:startMarker andDestMarker:endMarker successBlock:^(float dollars, BOOL isLyftLineValid, NSDictionary *standardPricing, NSDictionary *directions, NSArray *hotspots) {
        
        if (dollars > 0 && [self isBetterDealPrice:dollars distance:startDisNeighbor]) {
            self.bestPrice = dollars;
            self.bestStartDisNeigh = startDisNeighbor;
            self.bestLat = lat;
            self.bestLon = lon;
        }
        
        if ([self isBetterLyftDeal:self.lyftBestPrice
                       directions1:self.lyftBestDirections
                         disNeigh1:self.lyftBestStartDisNeigh
                            price2:standardPricing
                       directions2:directions
                         disNeigh2:startDisNeighbor]) {
            self.lyftBestDirections = directions;
            self.lyftBestPrice = standardPricing;
            self.lyftBestLat = lat;
            self.lyftBestLon = lon;
            self.lyftBestStartDisNeigh = startDisNeighbor;
        }
        
        [self optimizeForEnd];
    } failureBlock:^{
        [self optimizeForEnd];
    }];
    
    
}

- (void)optimizeForEnd {
    if (self.endDisNeigh < 40.0f || !globalStateInterface.shouldOptimizeDestination) {
        self.isDone = YES;
        return;
    }
    
    double endDisNeighbor = self.endDisNeigh;
    double metersPerLat = 111111.0f;
    double metersPerLon = 111111* cosf(self.start.latitude);
    
    double latDegEndNeigh = endDisNeighbor/metersPerLat;
    double lonDegEndNeigh = endDisNeighbor/metersPerLon;
    
    for (int i=-1; i<=1 ; i++) {
        for (int j=-1; j<=1 ; j++) {
            
            double lat = self.end.latitude + (i*latDegEndNeigh);
            double lon = self.end.longitude + (j*lonDegEndNeigh);
            
            if (abs(i*j) == 1) {
                lat = self.end.latitude + (i* sqrt(0.5) * latDegEndNeigh);
                lon = self.end.longitude + (j*sqrt(0.5) * lonDegEndNeigh);
            }
            
            double startLat = self.bestLat;
            double startLon = self.bestLon;
            
            NSDictionary *startMarker = [self markerForLatitude:startLat longitude:startLon];
            NSDictionary *endMarker = [self markerForLatitude:lat longitude:lon];
            
            [self getInfoForMarker:startMarker andDestMarker:endMarker successBlock:^(float dollars, BOOL isLyftLineValid, NSDictionary *standardPricing, NSDictionary *directions, NSArray *hotspots) {
                
                self.numEndRequests++;
                
                if (dollars > 0 && [self isBetterDealPrice:dollars distance:self.bestStartDisNeigh+endDisNeighbor]) {
                    self.bestPrice = dollars;
                    self.bestEndDisNeigh = endDisNeighbor;
                    self.bestEndLat = lat;
                    self.bestEndLon = lon;
                }
                
                [self checkForEnd];
            } failureBlock:^{
                self.numEndRequests++;
                
                [self checkForEnd];
            }];
        }
    }
}

- (void)checkForEnd {
    if (self.numEndRequests == 9) {
        self.isDone = YES;
    }
}

- (void)setIsDone:(BOOL)isDone {
    _isDone = isDone;
    /*if (isDone && self.lyftBestLat!=0.0 && self.lyftBestLon != 0.0) {
        CLLocationCoordinate2D s = CLLocationCoordinate2DMake(self.lyftBestLat, self.lyftBestLon);
        [[HTTPClient sharedInstance] getDirectionsFromStart:s end:self.end success:^(NSDictionary *directions) {
            self.lyftBestDirections = directions;
        } failure:^{
        }];
    }
     */
}

// Helper methods for Normal lyft
- (float)getBestDyncPricing {
    return self.lyftBestPrice[@"dynamicPricing"] ? [self.lyftBestPrice[@"dynamicPricing"] floatValue] : 0.0f;
}

- (float)getActDyncPricing {
    return self.lyftActPrice[@"dynamicPricing"] ? [self.lyftActPrice[@"dynamicPricing"] floatValue] : 0.0f;
}

#define METERS_PER_MILE 1609.344
- (float)getStandardPriceForDirections:(NSDictionary *)directions
                               pricing:(NSDictionary *)pricing {
    if (pricing[@"lyftPrice"]) {
        float lyftPrice = [pricing[@"lyftPrice"] floatValue]/100.0f;
        if (lyftPrice > 0) {
            return lyftPrice;
        }
    }
    if (directions && pricing) {
        float distanceMetres = [directions[@"distanceMetres"] floatValue];
        float timeSecs = [directions[@"durationSecs"] floatValue];
        
        float dyncPricingPercentage = [pricing[@"dynamicPricing"] floatValue];
        float minimum = [[pricing[@"minimum"] substringFromIndex:1] floatValue];
        float perMile = [[pricing[@"perMile"] substringFromIndex:1] floatValue];
        float perMinute = [[pricing[@"perMinute"] substringFromIndex:1] floatValue];
        float pickup = [[pricing[@"pickup"] substringFromIndex:1] floatValue];
        float insurance = 1.50f;
        
        float cost = pickup + (perMile * (distanceMetres/METERS_PER_MILE))
                    + (perMinute * (timeSecs/60.0f));
        cost = MAX(minimum, cost);
        cost  = cost + (cost * (dyncPricingPercentage/100.0f));
        cost += insurance;
        return cost;
    }
    return -1.0f;
}

- (float)getBestPrice {
    return [self getStandardPriceForDirections:self.lyftBestDirections
                                       pricing:self.lyftBestPrice];
}

- (float)getActPrice {
    return [self getStandardPriceForDirections:self.lyftActDirections
                                       pricing:self.lyftActPrice];
}
@end
