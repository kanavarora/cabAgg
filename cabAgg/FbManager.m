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
        
        [controller setInitialText:@"Just used cabalot to find myself a cheaper ride. @cabalotapp"];
        [controller addURL:[NSURL URLWithString:@"http://www.cabalotapp.com"]];
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
        [tweetSheet setInitialText:@"Just used cabalot to find myself a cheaper ride. @cabalotapp"];
        [globalStateInterface.mainVC presentViewController:tweetSheet animated:YES completion:nil];
        [globalStateInterface.eventLogger trackEventName:@"shareToTwitterAttempt" properties:@{@"enabled" :@(YES)}];
    } else {
        [[CabaggAlertController alertControllerWithTitle:@"Twitter account not set up" message:@"Please go to settings and add a twitter account"] show];
        [globalStateInterface.eventLogger trackEventName:@"shareToTwitterAttempt" properties:@{@"enabled" :@(NO)}];
    }
}
@end
