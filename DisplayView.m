//
//  DisplayView.m
//  cabAgg
//
//  Created by Kanav Arora on 1/4/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "DisplayView.h"
#import "CabAggHttpClient.h"
#import "ViewController.h"
#import "MainViewController.h"

#import "UberHTTPClient.h"

@interface DisplayView ()


@property (nonatomic, readwrite, weak) UILabel *actualPriceLab;
@property (nonatomic, readwrite, weak) UILabel *walkLinePriceLab;
@property (nonatomic, readwrite, weak) UILabel *actualUberPriceLab;
@property (nonatomic, readwrite, weak) UILabel *walkUberPriceLab;

@property (nonatomic, readwrite, weak) MainViewController *vc;

@end
@implementation DisplayView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithVC:(MainViewController *)vc{
    self = [super init];
    if (self) {
        self.vc = vc;
        [self displayResults];
        [self updateResults];
        self.layer.borderWidth = 1.0f;
    }
    return self;
}

- (void)displayResults {
    UILabel *actualPriceCap = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    UILabel *actualPriceLab = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 100, 20)];
    actualPriceCap.text = @"Act Lyft Line:";
    [self addSubview:actualPriceCap];
    [self addSubview:actualPriceLab];
    self.actualPriceLab = actualPriceLab;
    
    UILabel *walkLinePriceCap = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 100, 20)];
    UILabel *walkLinePriceLab = [[UILabel alloc] initWithFrame:CGRectMake(100, 30, 100, 20)];
    walkLinePriceCap.text = @"Walk Lyft Line:";
    [self addSubview:walkLinePriceCap];
    [self addSubview:walkLinePriceLab];
    self.walkLinePriceLab = walkLinePriceLab;
    
    // BUTTONS
    UIButton *lyftButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    lyftButton.frame = CGRectMake(200, 20, 50, 15);
    [lyftButton setTitle:@"Lyft" forState:UIControlStateNormal];
    [lyftButton addTarget:self action:@selector(lyftTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:lyftButton];
    
    UILabel *actualUberPriceCap = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 100, 20)];
    UILabel *actualUberPriceLab = [[UILabel alloc] initWithFrame:CGRectMake(100, 60, 200, 20)];
    actualUberPriceCap.text = @"Act Uber";
    [self addSubview:actualUberPriceCap];
    [self addSubview:actualUberPriceLab];
    self.actualUberPriceLab = actualUberPriceLab;
    
    // BUTTONS
    UIButton *actualUberXButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    actualUberXButton.frame = CGRectMake(0, 80, 100, 15);
    [actualUberXButton setTitle:@"UberX" forState:UIControlStateNormal];
    [actualUberXButton addTarget:self action:@selector(actualUberXTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:actualUberXButton];
    
    UIButton *actualUberPoolButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    actualUberPoolButton.frame = CGRectMake(120, 80, 100, 15);
    [actualUberPoolButton setTitle:@"UberPool" forState:UIControlStateNormal];
    [actualUberPoolButton addTarget:self action:@selector(actualUberPoolTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:actualUberPoolButton];
    
    
    UILabel *walkUberPriceCap = [[UILabel alloc] initWithFrame:CGRectMake(0, 110, 100, 20)];
    UILabel *walkUberPriceLab = [[UILabel alloc] initWithFrame:CGRectMake(100, 110, 200, 20)];
    walkUberPriceCap.text = @"Walk Uber";
    [self addSubview:walkUberPriceCap];
    [self addSubview:walkUberPriceLab];
    self.walkUberPriceLab = walkUberPriceLab;
    
    // BUTTONS
    UIButton *walkUberXButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    walkUberXButton.frame = CGRectMake(0, 130, 100, 15);
    [walkUberXButton setTitle:@"UberX" forState:UIControlStateNormal];
    [walkUberXButton addTarget:self action:@selector(walkUberXTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:walkUberXButton];
    
    UIButton *walkUberPoolButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    walkUberPoolButton.frame = CGRectMake(120, 130, 100, 15);
    [walkUberPoolButton setTitle:@"UberPool" forState:UIControlStateNormal];
    [walkUberPoolButton addTarget:self action:@selector(walkUberPoolTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:walkUberPoolButton];
    
    UIButton *reoptimizeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    reoptimizeButton.frame = CGRectMake(0, 175, 100, 20);
    [reoptimizeButton setTitle:@"Re-optimize" forState:UIControlStateNormal];
    [reoptimizeButton addTarget:self.vc action:@selector(reoptimize) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:reoptimizeButton];
    
}

- (void)updateResults {
    self.actualPriceLab.text = [@(self.client.actPrice/100.0f) stringValue];
    self.walkLinePriceLab.text = [@(self.client.bestPrice/100.0f) stringValue];
    UberHTTPClient *uberClient = [UberHTTPClient sharedInstance];
    self.actualUberPriceLab.text = [NSString stringWithFormat:@"%d-%d, %d-%d, x%.2f",
                                    (int)uberClient.actualLowEstimate,
                                    (int)uberClient.actualHighEstimate,
                                    (int)(uberClient.actualLowEstimate*0.8f),
                                    (int)(uberClient.actualHighEstimate*0.8f),
                                    uberClient.actualSurgeMultiplier];
    
    self.walkUberPriceLab.text = [NSString stringWithFormat:@"%d-%d, %d-%d, x%.2f",
                                  (int)uberClient.bestLowEstimate,
                                  (int)uberClient.bestHighEstimate,
                                  (int)(uberClient.bestLowEstimate*0.8f),
                                  (int)(uberClient.bestHighEstimate*0.8f),
                                  uberClient.bestSurgeMultiplier];
    
}

- (void)lyftTapped {
    NSString *url = [CabAggHttpClient deepLinkUrl];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)actualUberXTapped {
    UberHTTPClient *uberClient = [UberHTTPClient sharedInstance];
    NSString *url = [uberClient urlForPickupLatitude:uberClient.actualStart.latitude
                                     pickupLongitude:uberClient.actualStart.longitude
                                        dropLatitude:uberClient.actualEnd.latitude
                                       dropLongitude:uberClient.actualEnd.longitude
                                             isUberX:YES];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)actualUberPoolTapped {
    UberHTTPClient *uberClient = [UberHTTPClient sharedInstance];
    NSString *url = [uberClient urlForPickupLatitude:uberClient.actualStart.latitude
                                     pickupLongitude:uberClient.actualStart.longitude
                                        dropLatitude:uberClient.actualEnd.latitude
                                       dropLongitude:uberClient.actualEnd.longitude
                                             isUberX:NO];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)walkUberXTapped {
    UberHTTPClient *uberClient = [UberHTTPClient sharedInstance];
    NSString *url = [uberClient urlForPickupLatitude:uberClient.bestLat
                                     pickupLongitude:uberClient.bestLon
                                        dropLatitude:uberClient.actualEnd.latitude
                                       dropLongitude:uberClient.actualEnd.longitude
                                             isUberX:YES];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)walkUberPoolTapped {
    UberHTTPClient *uberClient = [UberHTTPClient sharedInstance];
    NSString *url = [uberClient urlForPickupLatitude:uberClient.bestLat
                                     pickupLongitude:uberClient.bestLon
                                        dropLatitude:uberClient.actualEnd.latitude
                                       dropLongitude:uberClient.actualEnd.longitude
                                             isUberX:NO];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end
