//
//  ResultsView.m
//  cabAgg
//
//  Created by Kanav Arora on 2/16/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "ResultsView.h"

#import "DisplayResultsCollectionView.h"
#import "ResultInfo.h"
#import "GlobalStateInterface.h"
#import "MainViewController.h"
#import "EventLogger.h"

@interface ResultsView ()

@property (nonatomic, readwrite, weak) DisplayResultsCollectionView *resultsCollectionView;

@property (nonatomic, readwrite, weak) UIButton *bookButton;

@end


@implementation ResultsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        DisplayResultsCollectionView *dv = [[DisplayResultsCollectionView alloc] initWithFrame:CGRectMake(0, kHeightOfBookButton, frame.size.width, frame.size.height-kHeightOfBookButton)];
        dv.resultsView = self;
        [self addSubview:dv];
        _resultsCollectionView = dv;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *greenBgImg = [UIImage imageNamed:@"RequestBox.png"];
        [button setBackgroundImage:greenBgImg forState:UIControlStateNormal];
        button.frame = CGRectMake((frame.size.width - kWidthofBookButton)/2.0f, 0, kWidthofBookButton, kHeightOfBookButton);
        [button addTarget:self action:@selector(didTapBookButton) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:@"Book" forState:UIControlStateNormal];

        [self addSubview:button];
        _bookButton = button;
    }
    return self;
}

- (void)setupCollectionView {
    [self.resultsCollectionView setupCollectionView];
}

- (void)updateResults {
    [self.resultsCollectionView updateResults];
}

- (ResultInfo *)selectedResultInfo {
    return [self.resultsCollectionView selectedResultInfo];
}

- (void)didChangeSelectionOfResult {
    NSString *text = [NSString stringWithFormat:@"Book %@", [ResultInfo titleForCabType:self.selectedResultInfo.cabType]];
    [self.bookButton setTitle:text forState:UIControlStateNormal];
}


- (void)openDeepUrl:(BOOL)isBestRoute {
    NSString *urlSt = [self.selectedResultInfo deepLinkUrl:isBestRoute];
    if (!urlSt) {
        return;
    }
    NSURL *url = [NSURL URLWithString:urlSt];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"App not installed"
                                                                       message:@"Install lyft/uber app to make this work"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:ok];
        [globalStateInterface.mainVC presentViewController:alert animated:YES completion:nil];
        
    }
}

- (void)didTapBookButton {
    [globalStateInterface.eventLogger trackEventName:@"book-tapped"
                                          properties:@{@"cabType":@(self.selectedResultInfo.cabType)}];
    if ([GlobalStateInterface areEqualLocations:self.selectedResultInfo.start
                                        andloc2:globalStateInterface.mainVC.pickupLocation]) {
        [self openDeepUrl:YES];
    } else {
        [self presentAlertViewWithOptions];
    }
}

- (void)presentAlertViewWithOptions {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Booking options"
                                message:@"Cabalot found a place close to you where the surge price is lower. Let's book that ride."
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* optOption = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             //Do some thing here
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             [self openDeepUrl:YES];
                             
                         }];
    UIAlertAction* altOption = [UIAlertAction
                             actionWithTitle:@"Feeling lazy! Book with original pickup location"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [self openDeepUrl:NO];
                                 
                             }];
    [alert addAction:optOption];
    [alert addAction:altOption];
    [globalStateInterface.mainVC presentViewController:alert animated:YES completion:nil];
}


- (void)startCalculatingResults {
    [self.resultsCollectionView setupResults];
}

@end
