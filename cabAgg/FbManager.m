//
//  FbManager.m
//  cabAgg
//
//  Created by Kanav Arora on 7/27/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "FbManager.h"

#import <Social/Social.h>
#import "GlobalStateInterface.h"
#import "MainViewController.h"

#import "CabaggAlertController.h"
#import "EventLogger.h"

@implementation FbManager

+ (void)shareToFb {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:@"Try using Cabalot to help you find cheaper cab rides!"];
        [controller addURL:[NSURL URLWithString:@"http://www.cabalotapp.com"]];
        //[controller addImage:[UIImage imageNamed:@"512.png"]];
        [globalStateInterface.mainVC presentViewController:controller animated:YES completion:nil];
        [globalStateInterface.eventLogger trackEventName:@"sharedToFb" properties:@{@"enabled" :@(YES)}];
    } else {
        [[CabaggAlertController alertControllerWithTitle:@"Facebook account not set up" message:@"Please go to settings and add a facebook account"] show];
        [globalStateInterface.eventLogger trackEventName:@"sharedToFb" properties:@{@"enabled" :@(NO)}];
    }
}

+ (void)shareToTwitter {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"Use @cabalotapp to find cheaper cab rides. Download it at www.cabalotapp.com"];
        [globalStateInterface.mainVC presentViewController:tweetSheet animated:YES completion:nil];
        [globalStateInterface.eventLogger trackEventName:@"shareToTwitterAttempt" properties:@{@"enabled" :@(YES)}];
    } else {
        [[CabaggAlertController alertControllerWithTitle:@"Twitter account not set up" message:@"Please go to settings and add a twitter account"] show];
        [globalStateInterface.eventLogger trackEventName:@"shareToTwitterAttempt" properties:@{@"enabled" :@(NO)}];
    }
}
@end
