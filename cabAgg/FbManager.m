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
#import <MessageUI/MessageUI.h>

@implementation FbManager

+ (void)shareToFb {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:@"Try using Cabalot to help you find cheaper cab rides!"];
        [controller addURL:[NSURL URLWithString:@"http://www.cabalotapp.com"]];
        controller.completionHandler = ^(SLComposeViewControllerResult result) {
            switch(result) {
                    //  This means the user cancelled without sending the Tweet
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"facebook sharing cancelled");
                    break;
                    //  This means the user hit 'Send'
                case SLComposeViewControllerResultDone:
                    [globalStateInterface.eventLogger trackEventName:@"sharedToFb" properties:nil];
                    break;
            }
            

        };
        [globalStateInterface.topController presentViewController:controller animated:YES completion:nil];
    } else {
        [[CabaggAlertController alertControllerWithTitle:@"Facebook account not set up" message:@"Please go to settings and add a facebook account"] show];
    }
}

+ (void)shareToTwitter:(NSString *)tweet {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:tweet];
        tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
            switch(result) {
                    //  This means the user cancelled without sending the Tweet
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"twitter sharing cancelled");
                    break;
                    //  This means the user hit 'Send'
                case SLComposeViewControllerResultDone:
                    [globalStateInterface.eventLogger trackEventName:@"sharedToTwitter" properties:nil];
                    break;
            }
        };
        [globalStateInterface.topController presentViewController:tweetSheet animated:YES completion:nil];
    } else {
        [[CabaggAlertController alertControllerWithTitle:@"Twitter account not set up" message:@"Please go to settings and add a twitter account"] show];
    }
}

+ (MFMessageComposeViewController *)shareToText {
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = @"I have been using cabalot to get cheaper rides. Download it at www.cabalotapp.com";
        return controller;
    }
    return nil;
}
@end
