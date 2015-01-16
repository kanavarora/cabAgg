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

#define kZoomFactor 2.0f
#define METERS_PER_MILE 1609.344

@interface MainViewController ()

@property (nonatomic, readwrite, weak) IBOutlet MKMapView *mapView;

@property (nonatomic, readwrite, weak) IBOutlet UIButton *myLocationButton;
@property (nonatomic, readwrite, weak) IBOutlet UIView *bottomBarView;
@property (nonatomic, readwrite, weak) IBOutlet SetDestinationView *pickupView;
@property (nonatomic, readwrite, weak) IBOutlet SetDestinationView *destinationView;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *actionButton;
@property (nonatomic, readwrite, weak) IBOutlet UIView *sliderParentView;
@property (nonatomic, readwrite, weak) IBOutlet UISlider *startSlider;
@property (nonatomic, readwrite, weak) IBOutlet UISlider *endSlider;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *startDistanceLabel;
@property (nonatomic, readwrite, weak) IBOutlet UILabel *endDistanceLabel;

@property (nonatomic, readwrite, strong) UIImageView *locatioSetterImageView;

@property (nonatomic, readwrite, strong) CLLocationManager *locationAuthorizationManager;
@property (nonatomic, readwrite, assign) BOOL isPickupSet;
@property (nonatomic, readwrite, assign) BOOL isDestinationSet;
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D pickupLocation;
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D destinationLocation;
@property (nonatomic, readwrite, strong) MKPointAnnotation *pickupAnno;
@property (nonatomic, readwrite, strong) MKPointAnnotation *destAnno;
@property (nonatomic, readwrite, strong) UIBarButtonItem *redoButton;

// results
@property (nonatomic, readwrite, weak) DisplayResultsCollectionView *resultsView;
@property (nonatomic, readwrite, strong) CabAggHttpClient *lyftClient;
@property (nonatomic, readwrite, strong) MKPointAnnotation *lyftLinePickupAnno;
@property (nonatomic, readwrite, strong) MKPointAnnotation *lyftLineDestAnno;
@property (nonatomic, readwrite, strong) MKPointAnnotation *uberPickupAnno;

@property (nonatomic, readwrite, strong) MKCircle *startRadial;
@property (nonatomic, readwrite, strong) MKCircle *endRadial;

@end

@implementation MainViewController

- (void)createLocationSetter {
    if (self.locatioSetterImageView) {
        return;
    }
    UIImage *image = [UIImage imageNamed:@"newLocation.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.clipsToBounds = YES;
    CGRect screenRect = self.mapView.bounds;
    imageView.frame = CGRectMake(screenRect.size.width/2.0f-20,
                                 screenRect.size.height/2.0f-20, 40, 40);
    self.locatioSetterImageView = imageView;
    [self.mapView addSubview:imageView];
    
    // do this only once too
    [self.pickupView setupIsPickup:YES parentVC:self];
    [self.destinationView setupIsPickup:NO parentVC:self];
    
    // do this once too
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    DisplayResultsCollectionView *dr = [[DisplayResultsCollectionView alloc] initWithFrame:CGRectMake(0, screenSize.height-200, screenSize.width, 200)];
    dr.hidden = YES;
    dr.backgroundColor = [UIColor clearColor];
    [dr setupCollectionView];
    [self.view addSubview:dr];
    self.resultsView = dr;
}

- (IBAction)startSliderValueChanged:(id)sender {
    [self.mapView removeOverlay:self.startRadial];
    float currentValue = self.startSlider.value;
    self.startDistanceLabel.text = [NSString stringWithFormat:@"Max walk from start:%.2f", currentValue];
    self.startRadial = [MKCircle circleWithCenterCoordinate:self.pickupLocation radius:[self startRadialInMeters]];
    [self.mapView addOverlay:self.startRadial];
    
}

- (IBAction)endSliderValueChanged:(id)sender {
    [self.mapView removeOverlay:self.endRadial];
    float currentValue = self.endSlider.value;
    self.endDistanceLabel.text = [NSString stringWithFormat:@"Max walk from end:%.2f", currentValue];
    self.endRadial = [MKCircle circleWithCenterCoordinate:self.destinationLocation radius:[self endRadialInMeters]];
    [self.mapView addOverlay:self.endRadial];
}

- (float)startRadialInMeters {
    return self.startSlider.value * METERS_PER_MILE;
}

- (float)endRadialInMeters {
    return self.endSlider.value * METERS_PER_MILE;
}

- (void)setupLocationMarkerForPickup {
    self.locatioSetterImageView.hidden = NO;
    self.locatioSetterImageView.image = [UIImage imageNamed:@"greenMapIcon.png"];
}

- (void)setupLocationMarkerForDestination {
    self.locatioSetterImageView.hidden = NO;
    self.locatioSetterImageView.image = [UIImage imageNamed:@"redMapIcon.png"];
}

- (void)clearLocationMarker {
    self.locatioSetterImageView.hidden = YES;
}

- (void)setupMapView {
    self.mapView.delegate = self;
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 37.8;
    zoomLocation.longitude= -122.4;
    
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, kZoomFactor*METERS_PER_MILE, kZoomFactor*METERS_PER_MILE);
    
    // 3
    [_mapView setRegion:viewRegion animated:YES];
    [self enableMyLocation];
    [self listenForMyLocationChangedProperty];
    
}

- (void)setupNavBar {
    self.title = @"CabAgg";
    UIBarButtonItem *redoButton = [[UIBarButtonItem alloc] initWithTitle:@"Redo" style:UIBarButtonItemStylePlain target:self action:@selector(reoptimize)];
    self.redoButton = redoButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupNavBar];
    [self setupActionButton];
    [self setupLocationMarker];
    [self setupMapView];
    float currentValue = self.startSlider.value;
    self.startDistanceLabel.text = [NSString stringWithFormat:@"Max walk from start:%.2f", currentValue];
    currentValue = self.endSlider.value;
    self.endDistanceLabel.text = [NSString stringWithFormat:@"Max walk from end:%.2f", currentValue];
    
    
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

- (void)setupLocationMarker {
    if (!self.isPickupSet) {
        //self.mapView.hidden = YES;
        self.locatioSetterImageView.hidden = NO;
    } else if (!self.isDestinationSet) {
        self.locatioSetterImageView.hidden = NO;
    } else {
        self.locatioSetterImageView.hidden = YES;
    }
}

- (void)hideRadialSettings {
    self.sliderParentView.hidden = YES;
    [self.mapView removeOverlay:self.startRadial];
    [self.mapView removeOverlay:self.endRadial];
    self.startRadial = self.endRadial = nil;
}

- (void)showRadialSettings {
    self.sliderParentView.hidden = NO;
    self.startRadial = [MKCircle circleWithCenterCoordinate:self.pickupLocation radius:[self startRadialInMeters]];
    self.endRadial = [MKCircle circleWithCenterCoordinate:self.destinationLocation radius:[self endRadialInMeters]];
    [self.mapView addOverlay:self.startRadial];
    [self.mapView addOverlay:self.endRadial];
}

- (void)setupActionButton {
    if (!self.isPickupSet) {
        [self.actionButton setBackgroundColor:UIColorFromRGB(0x00CC99)];
        [self.actionButton setTitle:@"Set Pickup" forState:UIControlStateNormal];
        [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setupLocationMarkerForPickup];
        [self hideRadialSettings];
        
    } else if (!self.isDestinationSet) {
        [self.actionButton setBackgroundColor:UIColorFromRGB(0xFF5050)];
        [self.actionButton setTitle:@"Set Destination" forState:UIControlStateNormal];
        [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setupLocationMarkerForDestination];
        [self hideRadialSettings];
    } else {
        [self.actionButton setBackgroundColor:UIColorFromRGB(0x0066FF)];
        [self.actionButton setTitle:@"Optimize" forState:UIControlStateNormal];
        [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self clearLocationMarker];
        [self showRadialSettings];
    }
}

- (IBAction)actionButtonTapped:(id)sender {
    if (!self.isPickupSet) {
        [self updatePickupLocation:self.mapView.centerCoordinate
                           address:nil
                        moveRegion:NO];
    } else if (!self.isDestinationSet) {
        [self updateDestinationLocation:self.mapView.centerCoordinate
                                address:nil
                             moveRegion:NO];
    } else {
        
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
        [self startUpdatingDisplayResults];
        self.navigationItem.rightBarButtonItem =  self.redoButton;
        [self hideRadialSettings];
    }
}

- (void)reoptimize {
    self.navigationItem.rightBarButtonItem = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startUpdatingDisplayResults) object:nil];
    self.resultsView.hidden = YES;
    self.bottomBarView.hidden = NO;
    [self.mapView removeAnnotation:self.lyftLinePickupAnno];
    [self.mapView removeAnnotation:self.lyftLineDestAnno];
    [self.mapView removeAnnotation:self.uberPickupAnno];
    self.lyftLinePickupAnno = self.lyftLineDestAnno = self.uberPickupAnno = nil;
    [self setupActionButton];
}

- (void)startUpdatingDisplayResults {
    [self.resultsView updateResults];
    [self updateAnnoForResults];
    [self performSelector:@selector(startUpdatingDisplayResults) withObject:nil afterDelay:0.1f];
}

- (void)clearPickupLocation {
    self.isPickupSet = NO;
    [self updatePickupAnnotation];
    [self setupActionButton];
}

- (void)clearDestinationLocation {
    self.isDestinationSet = NO;
    [self updateDestAnnotation];
    [self setupActionButton];
}

- (void)updatePickupLocation:(CLLocationCoordinate2D)pickupLocation
                     address:(NSString *)address
                  moveRegion:(BOOL)moveRegion {
    self.pickupLocation =  pickupLocation;
    self.isPickupSet = YES;
    if (moveRegion) {
        [self centerMapOnLocation:pickupLocation];
    }
    if (address) {
        [self.pickupView setWithAddress:address];
    } else {
        [self.pickupView setWithPin];
    }
    [self updatePickupAnnotation];
    [self setupActionButton];
}

- (void)updateDestinationLocation:(CLLocationCoordinate2D)destinationLocation
                          address:(NSString *)address
                       moveRegion:(BOOL)moveRegion {
    self.destinationLocation = destinationLocation;
    self.isDestinationSet = YES;
    if (moveRegion) {
        [self centerMapOnLocation:destinationLocation];
    }
    if (address) {
        [self.destinationView setWithAddress:address];
    } else {
        [self.destinationView setWithPin];
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
    if (self.isPickupSet) {
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
    if (self.isDestinationSet) {
        MKPointAnnotation *destAnno = [[MKPointAnnotation alloc] init];
        destAnno.coordinate = self.destinationLocation;
        [self.mapView addAnnotation:destAnno];
        self.destAnno = destAnno;
    }
}

- (void)updateAnnoForResults {
    CabAggHttpClient *lyftClient = self.lyftClient;
    UberHTTPClient *uberClient = [UberHTTPClient sharedInstance];
    if (!self.lyftLinePickupAnno) {
        self.lyftLinePickupAnno = [[MKPointAnnotation alloc] init];
        self.lyftLinePickupAnno.title = @"lyftLine:start";
        [self.mapView addAnnotation:self.lyftLinePickupAnno];
    }
    if (!self.lyftLineDestAnno) {
        self.lyftLineDestAnno = [[MKPointAnnotation alloc] init];
        self.lyftLineDestAnno.title = @"lyftLine:end";
        [self.mapView addAnnotation:self.lyftLineDestAnno];
    }
    if (!self.uberPickupAnno) {
        self.uberPickupAnno = [[MKPointAnnotation alloc] init];
        self.uberPickupAnno.title = @"uber:start";
        [self.mapView addAnnotation:self.uberPickupAnno];
    }
    
    [self.lyftLinePickupAnno setCoordinate:CLLocationCoordinate2DMake(lyftClient.bestLat, lyftClient.bestLon)];
    [self.lyftLineDestAnno setCoordinate:CLLocationCoordinate2DMake(lyftClient.bestEndLat, lyftClient.bestEndLon)];
    [self.uberPickupAnno setCoordinate:CLLocationCoordinate2DMake(uberClient.bestLat, uberClient.bestLon)];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (annotation == self.pickupAnno) {
        MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:self.pickupAnno reuseIdentifier:@"pickup"];
        pin.pinColor = MKPinAnnotationColorGreen;
        pin.animatesDrop = YES;
        pin.canShowCallout = YES;
        return pin;
    } else if (annotation == self.destAnno) {
        MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:self.destAnno reuseIdentifier:@"dest"];
        pin.pinColor = MKPinAnnotationColorRed;
        pin.animatesDrop = YES;
        pin.canShowCallout = YES;
        return pin;
    } else if (annotation == self.lyftLinePickupAnno) {
        MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:self.lyftLinePickupAnno reuseIdentifier:@"lyftPickup"];
        pin.pinColor = MKPinAnnotationColorPurple;
        pin.animatesDrop = YES;
        pin.canShowCallout = YES;
        return pin;
    } else if (annotation == self.lyftLineDestAnno) {
        MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:self.lyftLineDestAnno reuseIdentifier:@"lyftDest"];
        pin.pinColor = MKPinAnnotationColorPurple;
        pin.animatesDrop = YES;
        pin.canShowCallout = YES;
        return pin;
    } else if (annotation == self.uberPickupAnno) {
        MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:self.uberPickupAnno reuseIdentifier:@"uber"];
        pin.pinColor = MKPinAnnotationColorPurple;
        pin.animatesDrop = YES;
        pin.canShowCallout = YES;
        return pin;
    }
    return nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay{
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





@end
