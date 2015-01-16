//
//  ViewController.m
//  cabAgg
//
//  Created by Kanav Arora on 1/4/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "CabAggHttpClient.h"
#import "DisplayView.h"
#import "UberHTTPClient.h"
#import "SidecarHttpClient.h"

@interface ViewController ()
@property (nonatomic, readwrite, strong) GMSMapView *mapView;
@property (nonatomic, readwrite, strong) CLLocationManager *locationAuthorizationManager;
@property (nonatomic, readwrite, strong) CabAggHttpClient *client;

@property (nonatomic, readwrite, strong) UIButton *startLocationButton;
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D startTarget;
@property (nonatomic, readwrite, strong) GMSMarker *startMarker;

@property (nonatomic, readwrite, strong) UIButton *setDestinationButton;
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D destinationTarget;
@property (nonatomic, readwrite, strong) GMSMarker *destMarker;

@property (nonatomic, readwrite, strong) UIButton *optimizeButton;
@property (nonatomic, readwrite, strong) DisplayView *displayView;

@property (nonatomic, readwrite, strong) UIButton *redoButton;

@property (nonatomic, readwrite, strong) GMSMarker *lyftLineBestStartMaker;
@property (nonatomic, readwrite, strong) GMSMarker *lyftLineBestEndMaker;
@property (nonatomic, readwrite, strong) UIImageView *locationSetterMarker;

@property (nonatomic, readwrite, strong) UISlider *startDistSlider;
@property (nonatomic, readwrite, strong) UISlider *endDistSlider;


@property (nonatomic, readwrite, strong) GMSMarker *uberBestStartMarker;

@end

#define kDefaultZoomFactor 15
@implementation ViewController

- (void)viewDidLoad {
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.7833
                                                            longitude:-122.4167
                                                                 zoom:kDefaultZoomFactor];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    //self.mapView.myLocationEnabled = YES;
    [self enableMyLocation];
    self.view = self.mapView;
    self.mapView.delegate = self;
    self.mapView.settings.myLocationButton = YES;
    
    UIImage *image = [UIImage imageNamed:@"newLocation.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.clipsToBounds = YES;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    imageView.frame = CGRectMake(screenRect.size.width/2.0f,
                                 screenRect.size.height/2.0f, 10, 10);
    self.locationSetterMarker = imageView;
    [self.view addSubview:imageView];
    
    [self listenForMyLocationChangedProperty];
    [self putStartLocationButton];
    [self putSliders];
}

- (void)putSliders {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectMake(10, screenRect.size.height -40, 200.0, 10.0);
    UISlider *slider = [[UISlider alloc] initWithFrame:frame];
    [slider addTarget:self action:@selector(startSliderAction) forControlEvents:UIControlEventValueChanged];
    [slider setBackgroundColor:[UIColor clearColor]];
    slider.minimumValue = 0.0f;
    slider.maximumValue = 500.0f;
    slider.continuous = YES;
    slider.value = 300.0f;
    [self.view addSubview:slider];
    self.startDistSlider = slider;
    
    frame = CGRectMake(10, screenRect.size.height -20, 200.0, 10.0);
    UISlider *endslider = [[UISlider alloc] initWithFrame:frame];
    [endslider addTarget:self action:@selector(startSliderAction) forControlEvents:UIControlEventValueChanged];
    [endslider setBackgroundColor:[UIColor clearColor]];
    endslider.minimumValue = 0.0f;
    endslider.maximumValue = 500.0f;
    endslider.continuous = YES;
    endslider.value = 300.0f;
    [self.view addSubview:endslider];
    self.endDistSlider = endslider;
    
}
- (void)startSliderAction {
    
}

- (void)listenForMyLocationChangedProperty {
    [self.mapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context: nil];
}

- (void)stopListeningForMyLocationChangedProperty {
    [self.mapView removeObserver:self forKeyPath:@"myLocation"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"myLocation"] && [object isKindOfClass:[GMSMapView class]])
    {
        [self.mapView animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:self.mapView.myLocation.coordinate.latitude
                                                                          longitude:self.mapView.myLocation.coordinate.longitude
                                                                               zoom:kDefaultZoomFactor]];
        [self stopListeningForMyLocationChangedProperty];
    }
}

- (void)clearEverything {
    [self.startLocationButton removeFromSuperview];
    self.startMarker.map = nil;
    [self.setDestinationButton removeFromSuperview];
    self.destMarker.map = nil;
    [self.optimizeButton removeFromSuperview];
    [self.redoButton removeFromSuperview];
    self.lyftLineBestStartMaker.map = nil;
    self.lyftLineBestEndMaker.map = nil;
    self.uberBestStartMarker.map = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setDisplayResults) object:nil];
    if (self.displayView) {
        [self.displayView removeFromSuperview];
        self.displayView =  nil;
    }
}

- (void)putStartLocationButton {
    [self clearEverything];
    UIButton *setLocationButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [setLocationButton addTarget:self action:@selector(startLocationSelected) forControlEvents:UIControlEventTouchUpInside];
    setLocationButton.frame = CGRectMake(30, 30, 100, 20);
    [setLocationButton setTitle:@"Set Start" forState:UIControlStateNormal];
    [self.view addSubview:setLocationButton];
    self.startLocationButton = setLocationButton;
}


- (void)putStartLocationMarker {
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = self.startTarget;
    marker.title = @"start";
    marker.map = self.mapView;
    self.startMarker = marker;
}
- (void)startLocationSelected {
    self.startTarget =  self.mapView.camera.target;
    [self putSetDestinationButton];
}

- (void)putSetDestinationButton {
    [self clearEverything];
    [self putStartLocationMarker];
    UIButton *setLocationButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [setLocationButton addTarget:self action:@selector(destinationLocationSelected) forControlEvents:UIControlEventTouchUpInside];
    setLocationButton.frame = CGRectMake(30, 30, 100, 20);
    [setLocationButton setTitle:@"Set Destination" forState:UIControlStateNormal];
    [self.view addSubview:setLocationButton];
    self.setDestinationButton = setLocationButton;
}

- (void)putDestinationLocationMarker {
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = self.destinationTarget;
    marker.title = @"dest";
    marker.map = self.mapView;
    self.destMarker = marker;
}

- (void)destinationLocationSelected {
    self.destinationTarget =  self.mapView.camera.target;
    [self putDestinationLocationMarker];
    [self putOptimizeButton];
}

- (void)putOptimizeButton {
    [self clearEverything];
    [self putStartLocationMarker];
    [self putDestinationLocationMarker];
    UIButton *optmizeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [optmizeButton addTarget:self action:@selector(optimizeButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    optmizeButton.frame = CGRectMake(30, 30, 100, 20);
    [optmizeButton setTitle:@"Optimize" forState:UIControlStateNormal];
    [self.view addSubview:optmizeButton];
    self.optimizeButton = optmizeButton;
}

- (void)optimizeButtonSelected {
    [self clearEverything];
    [self putStartLocationMarker];
    [self putDestinationLocationMarker];
    [self putRedoButton];
    
    CabAggHttpClient *client = [[CabAggHttpClient alloc] init];
    [client optimizeForStart:self.startTarget
                         end:self.destinationTarget
            startDisNeighbor:self.startDistSlider.value
              endDisNeighbor:self.endDistSlider.value];
    self.client = client;
    DisplayView *dv = [[DisplayView alloc] initWithVC:nil];
    dv.client = client;
    CGRect rect = [UIScreen mainScreen].bounds;
    dv.frame = CGRectMake(rect.size.width-260, 30, 260, 200);
    [self.view addSubview:dv];
    self.displayView = dv;
    
    [[UberHTTPClient sharedInstance] getPriceEstimatesForStart:self.startTarget
                                                           end:self.destinationTarget
                                              startDisNeighbor:self.startDistSlider.value];
    /*[[SidecarHttpClient sharedInstance] getForStart:self.startTarget
                                                end:self.destinationTarget success:^{
    
                                                }];*/
    [self setDisplayResults];
}

- (void)setDisplayResults {
    [self.displayView updateResults];
    UberHTTPClient *uberClient = [UberHTTPClient sharedInstance];
    
    if (!self.lyftLineBestStartMaker) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
        marker.title = @"lyft line:start";
        marker.map = self.mapView;
        self.lyftLineBestStartMaker = marker;
    }
    if (!self.lyftLineBestEndMaker) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
        marker.title = @"lyft line:end";
        marker.map = self.mapView;
        self.lyftLineBestEndMaker = marker;
    }
    if (!self.uberBestStartMarker) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.icon = [GMSMarker markerImageWithColor:[UIColor blackColor]];
        marker.title = @"uber:start";
        marker.map = self.mapView;
        self.uberBestStartMarker = marker;
    }
    
    self.lyftLineBestStartMaker.map = self.mapView;
    self.lyftLineBestEndMaker.map = self.mapView;
    self.uberBestStartMarker.map = self.mapView;
    self.lyftLineBestStartMaker.position = CLLocationCoordinate2DMake(self.client.bestLat, self.client.bestLon);
    self.lyftLineBestEndMaker.position = CLLocationCoordinate2DMake(self.client.bestEndLat, self.client.bestEndLon);
    self.uberBestStartMarker.position = CLLocationCoordinate2DMake(uberClient.bestLat, uberClient.bestLon);
    
    [self performSelector:@selector(setDisplayResults) withObject:nil afterDelay:0.1f];
}

- (void)putRedoButton {
    UIButton *redoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [redoButton addTarget:self action:@selector(redoButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    redoButton.frame = CGRectMake(30, 30, 100, 20);
    [redoButton setTitle:@"Redo" forState:UIControlStateNormal];
    [self.view addSubview:redoButton];
    self.redoButton = redoButton;
}

- (void)redoButtonSelected {
    [self putStartLocationButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Rather than setting -myLocationEnabled to YES directly,
// call this method:

- (void)enableMyLocation
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusNotDetermined)
        [self requestLocationAuthorization];
    else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
        return; // we weren't allowed to show the user's location so don't enable
    else
        [self.mapView setMyLocationEnabled:YES];
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


@end
