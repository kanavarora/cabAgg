//
//  MainViewController.m
//  cabAgg
//
//  Created by Kanav Arora on 1/14/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "MainViewController.h"

#import "SetDestinationView.h"

#import "UberHTTPClient.h"
#import "CabAggHttpClient.h"
#import "GlobalStateInterface.h"
#import "DisplayResultsCollectionView.h"
#import "ResultsView.h"
#import "ResultInfo.h"
#import "CachedPolyline.h"
#import "HTTPClient.h"
#import "OnboardingContentViewController.h"
#import "OnboardingViewController.h"
#import "PaddingLabel.h"
#import "EventLogger.h"
#import "AboutViewController.h"
#import "FbManager.h"
#import "ShamelessPromotionViewController.h"

#define kZoomFactor 2.5f
#define METERS_PER_MILE 1609.344

typedef enum {
    MainViewStepSetPickup = 0,
    MainViewStepSetDest,
    MainViewStepOptimize,
} MainViewStep;

@interface MainViewController ()

@property (nonatomic, readwrite, weak) IBOutlet MKMapView *mapView;

@property (nonatomic, readwrite, weak) IBOutlet UIButton *myLocationButton;
@property (nonatomic, readwrite, weak) IBOutlet UIView *bottomBarView;
@property (nonatomic, readwrite, weak) IBOutlet SetDestinationView *pickupView;
@property (nonatomic, readwrite, weak) IBOutlet SetDestinationView *destinationView;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *actionButton;
@property (nonatomic, readwrite, weak) IBOutlet UIView *sliderParentView;
@property (nonatomic, readwrite, weak) IBOutlet UISlider *startSlider;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *startDistanceLabel;
@property (nonatomic, readwrite, weak) IBOutlet NSLayoutConstraint *myLocationConstraint;
@property (nonatomic, readwrite, weak) IBOutlet PaddingLabel *surgePricingLabel;
@property (nonatomic, readwrite, weak) IBOutlet NSLayoutConstraint *pickupWidthConstraint;

@property (nonatomic, readwrite, strong) UIImageView *locatioSetterImageView;

@property (nonatomic, readwrite, strong) CLLocationManager *locationAuthorizationManager;
@property (nonatomic, readwrite, assign) MainViewStep step;
@property (nonatomic, readwrite, strong) MKPointAnnotation *pickupAnno;
@property (nonatomic, readwrite, strong) MKPointAnnotation *destAnno;
@property (nonatomic, readwrite, strong) UIBarButtonItem *redoButton;

// results
@property (nonatomic, readwrite, weak) ResultsView *resultsView;
@property (nonatomic, readwrite, strong) CabAggHttpClient *lyftClient;
@property (nonatomic, readwrite, strong) MKPointAnnotation *lyftLinePickupAnno;
@property (nonatomic, readwrite, strong) MKPointAnnotation *lyftLineDestAnno;
@property (nonatomic, readwrite, strong) MKPointAnnotation *uberPickupAnno;
@property (nonatomic, readwrite, strong) CachedPolyline *startWalkLine;
@property (nonatomic, readwrite, strong) CachedPolyline *endWalkLine;

@property (nonatomic, readwrite, strong) MKCircle *startRadial;
@property (nonatomic, readwrite, strong) MKCircle *endRadial;

@property (nonatomic, readwrite, strong) UIBarButtonItem *aboutButton;

@end

@implementation MainViewController

- (CLLocationCoordinate2D)pickupLocation {
    return self.pickupView.pinLocation;
}

- (CLLocationCoordinate2D)destinationLocation {
    return self.destinationView.pinLocation;
}

- (void)createLocationSetter {
    if (self.locatioSetterImageView) {
        return;
    }
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.clipsToBounds = YES;
    //imageView.layer.borderColor = [[UIColor blackColor] CGColor];
    //imageView.layer.borderWidth = 1.0f;
    CGRect screenRect = self.mapView.bounds;
    imageView.frame = CGRectMake(screenRect.size.width/2.0f-8,
                                 screenRect.size.height/2.0f - 1, 32, 39);
    self.locatioSetterImageView = imageView;
    [self.mapView addSubview:imageView];
    
    [self setupActionButton];
    //[self setupLocationMarker];
    
    // do this only once too
    [self.pickupView setupIsPickup:YES parentVC:self];
    [self.destinationView setupIsPickup:NO parentVC:self];
    
    // do this once too
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    ResultsView *dr = [[ResultsView alloc] initWithFrame:CGRectMake(0, screenSize.height-(kHeightOfCell + kHeightOfBookButton), screenSize.width, kHeightOfCell+kHeightOfBookButton)];
    dr.hidden = YES;
    dr.backgroundColor = [UIColor clearColor];
    [dr setupCollectionView];
    [self.view insertSubview:dr belowSubview:self.myLocationButton];
    self.resultsView = dr;
    
    self.surgePricingLabel.layer.cornerRadius = self.surgePricingLabel.frame.size.height/2.0f;
    self.surgePricingLabel.layer.masksToBounds = YES;
    self.surgePricingLabel.hidden = YES;
    self.surgePricingLabel.textColor = [UIColor whiteColor];
    self.surgePricingLabel.backgroundColor = UIColorFromRGB(0x000000);
    self.surgePricingLabel.insets = UIEdgeInsetsMake(5, 10, 5, 10);
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)lyftPin {
    UIImage *orig = [UIImage imageNamed:@"lyft-pin.png"];
    UIImage *img = [MainViewController imageWithImage:orig scaledToSize:CGSizeMake(32, 39)];
    return img;
}

- (UIImage *)uberPin {
    UIImage *orig = [UIImage imageNamed:@"uber-pin.png"];
    return [MainViewController imageWithImage:orig scaledToSize:CGSizeMake(32, 39)];
}

- (IBAction)startSliderValueChanged:(id)sender {
    [self.mapView removeOverlay:self.startRadial];
    [self.mapView removeOverlay:self.endRadial];
    float currentValue = self.startSlider.value;
    //NSString *text = [NSString stringWithFormat:@"How far will you walk? %.2fmiles", currentValue];
    //NSMutableAttributedString *mtString = [[NSMutableAttributedString alloc] initWithString:text
      //                                                                           attributes:@{NSFore}];
    self.startDistanceLabel.text = [NSString stringWithFormat:@"How far are you willing to walk? %.2fmiles", currentValue];
    self.startRadial = [MKCircle circleWithCenterCoordinate:self.pickupLocation radius:[self startRadialInMeters]];
    [self.mapView addOverlay:self.startRadial];
    self.endRadial = [MKCircle circleWithCenterCoordinate:self.destinationLocation radius:[self endRadialInMeters]];
    if (globalStateInterface.shouldOptimizeDestination) {
        [self.mapView addOverlay:self.endRadial];
    }
}

- (float)startRadialInMeters {
    return self.startSlider.value * METERS_PER_MILE;
}

- (float)endRadialInMeters {
    return self.startSlider.value * METERS_PER_MILE;
}

- (void)setupLocationMarkerForPickup {
    self.locatioSetterImageView.hidden = NO;
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:self.destAnno
                                                               reuseIdentifier:@"tmp1"];
    pin.pinColor = MKPinAnnotationColorGreen;
    UIImage *image = pin.image;
    self.locatioSetterImageView.image = image;
}

- (void)setupLocationMarkerForDestination {
    self.locatioSetterImageView.hidden = NO;
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:self.destAnno
                                                               reuseIdentifier:@"tmp2"];
    pin.pinColor = MKPinAnnotationColorRed;
    UIImage *image = pin.image;
    self.locatioSetterImageView.image = image;
}

- (void)clearLocationMarker {
    self.locatioSetterImageView.hidden = YES;
}

- (void)updateLocationMarker {
    switch (self.step) {
        case MainViewStepSetPickup:
        {
            [self setupLocationMarkerForPickup];
            break;
        }
        case MainViewStepSetDest:
        {
            [self setupLocationMarkerForDestination];
            break;
        }
        case MainViewStepOptimize:
        {
            [self clearLocationMarker];
            break;
        }
    }
}

- (void)setupMapView:(BOOL)hasOnboarded {
    self.mapView.delegate = self;
    /*
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 37.8;
    zoomLocation.longitude= -122.4;
    
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, kZoomFactor*METERS_PER_MILE, kZoomFactor*METERS_PER_MILE);
    
    // 3
    [_mapView setRegion:viewRegion animated:YES];
     */
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"startLat"] && [userDefaults objectForKey:@"startLng"]) {
        [self centerMapOnLocation:CLLocationCoordinate2DMake([userDefaults floatForKey:@"startLat"], [userDefaults floatForKey:@"startLng"])];
    }

    if (hasOnboarded) {
        [self enableMyLocation];
        [self listenForMyLocationChangedProperty];
    }
}

- (CLLocationCoordinate2D)centerOfMap {
    return self.mapView.centerCoordinate;
}

- (void)showAboutView {
    AboutViewController *aboutVC = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
    [self.navigationController pushViewController:aboutVC animated:YES];
}

- (void)setupNavBar {
    self.title = @"CABALOT";
    UIImage *img = [UIImage imageNamed:@"logo.png"];
    UIImageView *v = [[UIImageView alloc] initWithImage:img];
    self.navigationItem.titleView = v;
    UIBarButtonItem *redoButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(reoptimize)];
    self.redoButton = redoButton;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showAboutView)];
    self.aboutButton = rightButton;
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    BOOL hasOnboarded = [[[NSUserDefaults standardUserDefaults] objectForKey:@"hasOnboarded"] boolValue];
    [[HTTPClient sharedInstance] startApp];
    [self setupNavBar];
    [self setupMapView:hasOnboarded];
    [self startSliderValueChanged:self.startSlider];
    [self hideRadialSettings];
    if (!hasOnboarded) {
        [self showOnboarding];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self createLocationSetter];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)centerMapOnLocation:(CLLocationCoordinate2D)loc {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(loc, kZoomFactor*METERS_PER_MILE, kZoomFactor*METERS_PER_MILE);
    
    // 3
    [_mapView setRegion:viewRegion animated:YES];
}

- (void)centerMapToIncludeLocations:(CLLocationCoordinate2D)loc1 loc2:(CLLocationCoordinate2D)loc2 {
    double midLat = (loc1.latitude+loc2.latitude)/2.0;
    double midLon = (loc1.longitude+loc2.longitude)/2.0;
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(midLat, midLon);
    
    CLLocation *pointALocation = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
    CLLocation *pointBLocation = [[CLLocation alloc] initWithLatitude:loc2.latitude longitude:loc2.longitude];
    CLLocationDistance d = [pointALocation distanceFromLocation:pointBLocation];
    d = d*1.2;
    MKCoordinateRegion r = MKCoordinateRegionMakeWithDistance(center, 2*d, 2*d);
    [_mapView setRegion:r animated:YES];
    
}

- (void)hideRadialSettings {
    self.myLocationConstraint.constant = 1;
    self.sliderParentView.hidden = YES;
    [self.mapView removeOverlay:self.startRadial];
    [self.mapView removeOverlay:self.endRadial];
    self.startRadial = self.endRadial = nil;
}

- (void)showRadialSettings {
    [self.mapView removeOverlay:self.startRadial];
    [self.mapView removeOverlay:self.endRadial];
    self.myLocationConstraint.constant = 1 + self.sliderParentView.frame.size.height;
    self.sliderParentView.hidden = NO;
    self.startRadial = [MKCircle circleWithCenterCoordinate:self.pickupLocation radius:[self startRadialInMeters]];
    self.endRadial = [MKCircle circleWithCenterCoordinate:self.destinationLocation radius:[self endRadialInMeters]];
    [self.mapView addOverlay:self.startRadial];
    if (globalStateInterface.shouldOptimizeDestination) {
        [self.mapView addOverlay:self.endRadial];
    }
    [self centerMapToIncludeLocations:self.pickupLocation loc2:self.destinationLocation];
}

- (void)setupActionButton {
    BOOL updateLocationImmediately = YES;
    switch (self.step) {
        case MainViewStepSetPickup: {
            [self.actionButton setBackgroundColor:UIColorFromRGB(0x7ED321)];
            [self.actionButton setTitle:@"Set Pickup" forState:UIControlStateNormal];
            [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self hideRadialSettings];
            if (self.pickupView.isSetOnce) {
                [self centerMapOnLocation:self.pickupView.pinLocation];
                updateLocationImmediately = NO;
            }
            [self.pickupView unlockIt];
            [self.destinationView lockIt];
            break;
        }
        case MainViewStepSetDest: {
            [self.actionButton setBackgroundColor:UIColorFromRGB(0xDD4658)];
            [self.actionButton setTitle:@"Set Destination" forState:UIControlStateNormal];
            [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self hideRadialSettings];
            if (self.destinationView.isSetOnce) {
                [self centerMapOnLocation:self.destinationView.pinLocation];
                updateLocationImmediately = NO;
            }
            [self.pickupView lockIt];
            [self.destinationView unlockIt];
            break;
        }
        case MainViewStepOptimize: {
            [self.actionButton setBackgroundColor:UIColorFromRGB(0x0066FF)];
            [self.actionButton setTitle:@"Optimize" forState:UIControlStateNormal];
            [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self showRadialSettings];
            [self.pickupView lockIt];
            [self.destinationView lockIt];
            break;
        }
    }
    if (updateLocationImmediately) {
        [self updatePickupAnnotation];
        [self updateDestAnnotation];
        [self updateLocationMarker];
    } else {
        [self clearLocationMarker];
    }
    [self updateSetPickupViews];
}

- (IBAction)actionButtonTapped:(id)sender {
    switch (self.step) {
        case MainViewStepSetPickup: {
            [self updatePickupLocation:self.mapView.centerCoordinate
                               address:nil
                            moveRegion:NO];
            break;
        }
        case MainViewStepSetDest: {
            [self updateDestinationLocation:self.mapView.centerCoordinate
                                    address:nil
                                 moveRegion:NO];
            break;
        }
        case MainViewStepOptimize: {
            NSDictionary *properties = @{@"startLat": @(self.pickupLocation.latitude),
                                         @"startLon": @(self.pickupLocation.longitude),
                                         @"endLat" : @(self.destinationLocation.latitude),
                                         @"endLon" : @(self.destinationLocation.longitude),
                                         @"dis" : @([self startRadialInMeters])};
            NSMutableDictionary *exProps = [NSMutableDictionary dictionaryWithDictionary:properties];
            
            [globalStateInterface.eventLogger trackEventName:@"optimize-tapped" properties:exProps];
            // optimize Lyft
            CabAggHttpClient *client = [[CabAggHttpClient alloc] init];
            [client optimizeForStart:self.pickupLocation
                                 end:self.destinationLocation
                    startDisNeighbor:[self startRadialInMeters]
                      endDisNeighbor:[self endRadialInMeters]];
            self.lyftClient = client;
            
            // optimize uber
            [[UberHTTPClient sharedInstance] getPriceEstimatesForStart:self.pickupLocation
                                                                   end:self.destinationLocation
                                                      startDisNeighbor:[self startRadialInMeters]];
            
            
            self.bottomBarView.hidden = YES;
            self.resultsView.hidden = NO;
            [self.resultsView startCalculatingResults];
            [self startUpdatingDisplayResults];
            self.navigationItem.leftBarButtonItem = self.redoButton;
            //self.navigationItem.rightBarButtonItem = nil;
            [self hideRadialSettings];
            self.myLocationConstraint.constant = -self.bottomBarView.frame.size.height + kHeightOfCell - 1;
            
            [globalStateInterface increaseNumOptimize];
            break;
        }
    }
}

- (void)reoptimize {
    [globalStateInterface.eventLogger trackEventName:@"reoptimize-tapped" properties:@{}];
    self.navigationItem.leftBarButtonItem = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startUpdatingDisplayResults) object:nil];
    self.resultsView.hidden = YES;
    self.bottomBarView.hidden = NO;
    [self.mapView removeAnnotation:self.lyftLinePickupAnno];
    [self.mapView removeAnnotation:self.lyftLineDestAnno];
    [self.mapView removeAnnotation:self.uberPickupAnno];
    [self.mapView removeOverlay:self.startWalkLine.polyline];
    [self.mapView removeOverlay:self.endWalkLine.polyline];
    self.lyftLinePickupAnno = self.lyftLineDestAnno = self.uberPickupAnno = nil;
    self.startWalkLine = self.endWalkLine = nil;
    self.surgePricingLabel.hidden = YES;
    [self setupActionButton];
}

- (void)startUpdatingDisplayResults {
    [self.resultsView updateResults];
    [self updateAnnoForResults];
    [self performSelector:@selector(startUpdatingDisplayResults) withObject:nil afterDelay:0.1f];
}

- (void)clearPickupLocation {
    self.step = MainViewStepSetPickup;
    //[self updatePickupAnnotation];
    [self setupActionButton];
}

- (void)clearDestinationLocation {
    self.step = MainViewStepSetDest;
    //[self updateDestAnnotation];
    [self setupActionButton];
}

- (BOOL)centerOnPickup {
    if (self.step == MainViewStepSetPickup && ![GlobalStateInterface areEqualLocations:self.pickupLocation andloc2:CLLocationCoordinate2DMake(0, 0)]) {
        [self centerMapOnLocation:self.pickupLocation];
        return YES;
    }
    return NO;
}

- (BOOL)centerOnDestination {
    if (self.step == MainViewStepSetDest && ![GlobalStateInterface areEqualLocations:self.destinationLocation andloc2:CLLocationCoordinate2DMake(0, 0)]) {
        [self centerMapOnLocation:self.destinationLocation];
        return YES;
    }
    return NO;
}

- (void)updatePickupLocation:(CLLocationCoordinate2D)pickupLocation
                     address:(NSString *)address
                  moveRegion:(BOOL)moveRegion {
    self.step = MainViewStepSetDest;
    if (moveRegion) {
        [self centerMapOnLocation:pickupLocation];
    }
    if (address) {
        [self.pickupView setWithAddress:address location:pickupLocation];
    } else {
        [self.pickupView setWithPin:pickupLocation];
    }
    [self updatePickupAnnotation];
    [self setupActionButton];
}

- (void)updateDestinationLocation:(CLLocationCoordinate2D)destinationLocation
                          address:(NSString *)address
                       moveRegion:(BOOL)moveRegion {
    self.step = MainViewStepOptimize;
    if (moveRegion) {
        [self centerMapOnLocation:destinationLocation];
    }
    if (address) {
        [self.destinationView setWithAddress:address location:destinationLocation];
    } else {
        [self.destinationView setWithPin:destinationLocation];
    }
    [self updateDestAnnotation];
    [self setupActionButton];
}

#pragma mark - Annotations
- (void)updatePickupAnnotation {
    if (self.pickupAnno) {
        [self.mapView removeAnnotation:self.pickupAnno];
        self.pickupAnno = nil;
    }
    if (self.step != MainViewStepSetPickup) {
        MKPointAnnotation *pickupAnno = [[MKPointAnnotation alloc] init];
        pickupAnno.coordinate = self.pickupLocation;
        [self.mapView addAnnotation:pickupAnno];
        self.pickupAnno = pickupAnno;
    }
}

- (void)updateDestAnnotation {
    if (self.destAnno) {
        [self.mapView removeAnnotation:self.destAnno];
        self.destAnno = nil;
    }
    if (self.step == MainViewStepOptimize) {
        MKPointAnnotation *destAnno = [[MKPointAnnotation alloc] init];
        destAnno.coordinate = self.destinationLocation;
        [self.mapView addAnnotation:destAnno];
        self.destAnno = destAnno;
    }
}

- (void)updateSetPickupViews {
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    switch (self.step) {
        case MainViewStepSetPickup:
        {
            self.pickupWidthConstraint.constant = (screenWidth * 0.67f);
            break;
        }
        case MainViewStepSetDest:
        {
            self.pickupWidthConstraint.constant = (screenWidth * 0.33f);
            break;
        }
        case MainViewStepOptimize:
        {
            self.pickupWidthConstraint.constant = (screenWidth * 0.50f);
            break;
        }
    }
    [UIView animateWithDuration:.3 animations:^{
        [self.bottomBarView setNeedsLayout];
        [self.bottomBarView layoutIfNeeded];
    }];
}

- (void)updateAnnoForResults {
    ResultInfo *ri = [self.resultsView selectedResultInfo];
    switch (ri.cabType) {
        case CabTypeLyftLine:
        {
            if (!self.lyftLinePickupAnno) {
                self.lyftLinePickupAnno = [[MKPointAnnotation alloc] init];
                self.lyftLinePickupAnno.title = @"lyft:start";
                [self.mapView addAnnotation:self.lyftLinePickupAnno];
            }
            if (!self.lyftLineDestAnno) {
                self.lyftLineDestAnno = [[MKPointAnnotation alloc] init];
                self.lyftLineDestAnno.title = @"lyft:end";
                [self.mapView addAnnotation:self.lyftLineDestAnno];
            }
            if (self.uberPickupAnno) {
                [self.mapView removeAnnotation:self.uberPickupAnno];
                self.uberPickupAnno = nil;
            }
            CLLocationCoordinate2D lyftBestPickupLoc = ri.start;
            if ([GlobalStateInterface areEqualLocations:lyftBestPickupLoc andloc2:self.pickupLocation]) {
                [self.mapView removeAnnotation:self.lyftLinePickupAnno];
                self.lyftLinePickupAnno = nil;
            } else {
                [self.lyftLinePickupAnno setCoordinate:lyftBestPickupLoc];
            }
            
            CLLocationCoordinate2D lyftBestDropLoc = ri.end;
            
            if ([GlobalStateInterface areEqualLocations:lyftBestDropLoc andloc2:self.destinationLocation]) {
                [self.mapView removeAnnotation:self.lyftLineDestAnno];
                self.lyftLineDestAnno = nil;
            } else {
                [self.lyftLineDestAnno setCoordinate:lyftBestDropLoc];
            }
            
            break;
        }
            
        case CabTypeLyft:
        {
            if (!self.lyftLinePickupAnno) {
                self.lyftLinePickupAnno = [[MKPointAnnotation alloc] init];
                self.lyftLinePickupAnno.title = @"lyft:start";
                [self.mapView addAnnotation:self.lyftLinePickupAnno];
            }
            if (self.lyftLineDestAnno) {
                [self.mapView removeAnnotation:self.lyftLineDestAnno];
                self.lyftLineDestAnno = nil;
            }
            if (self.uberPickupAnno) {
                [self.mapView removeAnnotation:self.uberPickupAnno];
                self.uberPickupAnno = nil;
            }
            CLLocationCoordinate2D lyftBestPickupLoc = ri.start;
            if ([GlobalStateInterface areEqualLocations:lyftBestPickupLoc andloc2:self.pickupLocation]) {
                [self.mapView removeAnnotation:self.lyftLinePickupAnno];
                self.lyftLinePickupAnno = nil;
            } else {
                [self.lyftLinePickupAnno setCoordinate:lyftBestPickupLoc];
            }
            break;
        }
            
        case CabTypeUberPool:
        case CabTypeUberX:
        {
            if (self.lyftLinePickupAnno) {
                [self.mapView removeAnnotation:self.lyftLinePickupAnno];
                self.lyftLinePickupAnno = nil;
            }
            
            if (self.lyftLineDestAnno) {
                [self.mapView removeAnnotation:self.lyftLineDestAnno];
                self.lyftLineDestAnno = nil;
            }
            
            if (!self.uberPickupAnno) {
                self.uberPickupAnno = [[MKPointAnnotation alloc] init];
                self.uberPickupAnno.title = @"uber:start";
                [self.mapView addAnnotation:self.uberPickupAnno];
            }
            
            CLLocationCoordinate2D uberBestLoc = ri.start;
            if ([GlobalStateInterface areEqualLocations:uberBestLoc andloc2:self.pickupLocation]) {
                [self.mapView removeAnnotation:self.uberPickupAnno];
                self.uberPickupAnno = nil;
            } else {
                [self.uberPickupAnno setCoordinate:uberBestLoc];
            }
            
            break;
        }
    }

    if (!self.startWalkLine) {
        self.startWalkLine = [[CachedPolyline alloc] init];
    }
    if ([self.startWalkLine shouldUpdateWithStart:self.pickupLocation end:ri.start]) {
        if (self.startWalkLine.polyline) {
            [self.mapView removeOverlay:self.startWalkLine.polyline];
        }
        [self.startWalkLine updateWithStart:self.pickupLocation end:ri.start];
        if (self.startWalkLine.polyline) {
            [self.mapView addOverlay:self.startWalkLine.polyline];
        }
    }
    
    if (!self.endWalkLine) {
        self.endWalkLine = [[CachedPolyline alloc] init];
    }
    if ([self.endWalkLine shouldUpdateWithStart:self.pickupLocation end:ri.start]) {
        if (self.endWalkLine.polyline) {
            [self.mapView removeOverlay:self.endWalkLine.polyline];
        }
        [self.endWalkLine updateWithStart:self.destinationLocation end:ri.end];
        if (self.endWalkLine.polyline) {
            [self.mapView addOverlay:self.endWalkLine.polyline];
        }
    }
    
    // surge pricing label
    float diff = ri.differenceSurgePricing;
    if (diff > 0) {
        self.surgePricingLabel.hidden = NO;
        self.surgePricingLabel.text = [NSString stringWithFormat:@"%d%% less Surge", (int)diff];
    } else {
        self.surgePricingLabel.hidden = YES;
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (annotation == self.pickupAnno) {
        MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:self.pickupAnno reuseIdentifier:@"pickup"];
        pin.pinColor = MKPinAnnotationColorGreen;
        pin.canShowCallout = YES;
        return pin;
    } else if (annotation == self.destAnno) {
        MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:self.destAnno reuseIdentifier:@"dest"];
        pin.pinColor = MKPinAnnotationColorRed;
        pin.canShowCallout = YES;
        return pin;
    } else if (annotation == self.lyftLinePickupAnno) {
        MKAnnotationView *pin = [[MKAnnotationView alloc] initWithAnnotation:self.lyftLinePickupAnno reuseIdentifier:@"lyftPickup"];
        pin.image = [self lyftPin];
        pin.canShowCallout = YES;
        pin.layer.anchorPoint = CGPointMake(0.5, 1.0);
        return pin;
    } else if (annotation == self.lyftLineDestAnno) {
        MKAnnotationView *pin = [[MKAnnotationView alloc] initWithAnnotation:self.lyftLineDestAnno reuseIdentifier:@"lyftDest"];
        pin.image = [self lyftPin];
        pin.canShowCallout = YES;
        pin.layer.anchorPoint = CGPointMake(0.5, 1.0f);
        return pin;
    } else if (annotation == self.uberPickupAnno) {
        MKAnnotationView *pin = [[MKAnnotationView alloc] initWithAnnotation:self.uberPickupAnno reuseIdentifier:@"uber"];
        pin.image = [self uberPin];
        pin.canShowCallout = YES;
        pin.layer.anchorPoint = CGPointMake(0.5, 1.0);
        //pin.layer.anchorPoint = CGPointMake(0.75f, 0.5f + (1.0f/39));
        return pin;
    }
    return nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay{
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircle *circle = overlay;
        MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:circle];
        
        if (circle == self.startRadial)
        {
            circleView.fillColor = UIColorFromRGB(0x00CC99);
            circleView.alpha = 0.25;
        }
        else if (circle == self.endRadial)
        {
            circleView.fillColor = UIColorFromRGB(0xFF5050);
            circleView.alpha = 0.25;
        }
        return circleView;
    } else if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyLine = (MKPolyline *)overlay;
        MKPolylineView *lineView = [[MKPolylineView alloc] initWithPolyline:polyLine];
        lineView.fillColor = [UIColor blackColor];
        lineView.strokeColor = [UIColor blackColor];
        lineView.lineWidth = 3;
        lineView.lineDashPattern = @[@(2), @(5)];
        return lineView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (self.step == MainViewStepSetPickup) {
        [self.pickupView setWithPin:self.mapView.centerCoordinate];
    } else if (self.step == MainViewStepSetDest) {
        [self.destinationView setWithPin:self.mapView.centerCoordinate];
    }
    [self updatePickupAnnotation];
    [self updateDestAnnotation];
    [self updateLocationMarker];
}

- (void)canceledLocationSearch:(BOOL)isPickup {
    if (isPickup) {
        [self.pickupView setWithPin:self.mapView.centerCoordinate];
    } else {
        [self.destinationView setWithPin:self.mapView.centerCoordinate];
    }
}

- (void)unlockedLocation:(BOOL)isPickup {
    switch (self.step) {
        case MainViewStepSetPickup:
        {
            if (isPickup) {
                // assert should never happen
            } else {
                [self clearDestinationLocation];
            }
            break;
        }
        case MainViewStepSetDest:
        {
            if (isPickup) {
                [self clearPickupLocation];
            } else {
                // assert should never happen
            }
            break;
        }
        case MainViewStepOptimize:
        {
            if (isPickup) {
                [self clearPickupLocation];
            } else {
                [self clearDestinationLocation];
            }
            break;
        }
        
    }
}

#pragma mark- Location
- (IBAction)myLocationButtonTapped:(id)sender {
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}

- (CLLocationCoordinate2D)currentMapLocation {
    return self.mapView.centerCoordinate;
}

- (void)enableMyLocation
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusNotDetermined)
        [self requestLocationAuthorization];
    else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
        return; // we weren't allowed to show the user's location so don't enable
    else
        [self.mapView setShowsUserLocation:YES];
}

// Ask the CLLocationManager for location authorization,
// and be sure to retain the manager somewhere on the class

- (void)requestLocationAuthorization
{
    _locationAuthorizationManager = [[CLLocationManager alloc] init];
    _locationAuthorizationManager.delegate = self;
    
    [_locationAuthorizationManager requestWhenInUseAuthorization];
}

// Handle the authorization callback. This is usually
// called on a background thread so go back to main.

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusNotDetermined) {
        [self performSelectorOnMainThread:@selector(enableMyLocation) withObject:nil waitUntilDone:[NSThread isMainThread]];
        
        _locationAuthorizationManager.delegate = nil;
        _locationAuthorizationManager = nil;
    }
}


- (void)listenForMyLocationChangedProperty {
    [self.mapView.userLocation addObserver:self forKeyPath:@"location" options:NSKeyValueObservingOptionNew context: nil];
}

- (void)stopListeningForMyLocationChangedProperty {
    [self.mapView.userLocation removeObserver:self forKeyPath:@"location"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"location"] && [object isKindOfClass:[MKUserLocation class]])
    {
        [self centerMapOnLocation:self.mapView.userLocation.location.coordinate];
        [self stopListeningForMyLocationChangedProperty];
    }
}

- (void)showOnboarding {
    OnboardingContentViewController *firstPage = [OnboardingContentViewController contentWithTitle:@"Welcome" body:@"Cabalot helps you find fares for different car services. Just set your pickup and dropoff points and let the app show you your options" image:[UIImage imageNamed:@"logo-big.png"] buttonText:nil action:^{
    }];
    
    OnboardingContentViewController *secondPage = [OnboardingContentViewController contentWithTitle:@"Escape Surge" body:@"Cabalot is smart. It helps you find places nearby which have lesser surge pricing than where you currently are. So you can walk to nearby places and save even more money" image:[UIImage imageNamed:@"onboarding1.png"] buttonText:nil    action:^{
    }];
    
    OnboardingContentViewController *fourthPage= [OnboardingContentViewController contentWithTitle:@"Easy booking" body:@"Once you have selected the most convenient option, you can book that ride from within the app itself." image:[UIImage imageNamed:@"logo-big.png"] buttonText:nil    action:^{
    }];
    
    OnboardingContentViewController *fifthPage= [OnboardingContentViewController contentWithTitle:@"Ready" body:@"That's all there is to Cabalot! Happy savings and may the choice be forever with you!" image:[UIImage imageNamed:@"logo-big.png"] buttonText:@"Done"    action:^{
        [self dismissViewControllerAnimated:YES completion:nil];
        [self enableMyLocation];
        [self listenForMyLocationChangedProperty];
    }];

    // Image
    OnboardingViewController *onboardingVC = [OnboardingViewController onboardWithBackgroundImage:[UIImage imageNamed:@"stock-photo.jpeg"] contents:@[firstPage, secondPage, fourthPage, fifthPage]];
    onboardingVC.fontName = @"Helvetica-Light";
    onboardingVC.titleFontSize = 26;
    onboardingVC.bodyFontSize = 18;
    onboardingVC.topPadding = 40;
    onboardingVC.underIconPadding = 20;
    onboardingVC.underTitlePadding = 25;
    onboardingVC.bottomPadding = 10;
    [self presentViewController:onboardingVC animated:NO completion:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"hasOnboarded"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



@end
