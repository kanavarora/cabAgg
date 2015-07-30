//
//  ShamelessPromotionViewController.m
//  cabAgg
//
//  Created by Kanav Arora on 7/28/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "ShamelessPromotionViewController.h"

#import "UIView+Border.h"
#import "GlobalStateInterface.h"
#import "FbManager.h"
#import <MessageUI/MessageUI.h>
#import "CabaggAlertController.h"
#import "EventLogger.h"
#import "ModifiedHitAreaButton.h"

@interface ShamelessPromotionViewController ()

@property (nonatomic, readwrite, weak) IBOutlet UILabel *textLabel;

@property (nonatomic, readwrite, weak) IBOutlet UIButton *fbButton;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *twitterButton;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *textButton;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *emailButton;
@property (nonatomic, readwrite, weak) IBOutlet ModifiedHitAreaButton *closeButton;

@property (nonatomic, readwrite, assign) int level;
@property (nonatomic, readwrite, assign) ShamelessDialogType type;

@end

@implementation ShamelessPromotionViewController

- (id)initWithType:(ShamelessDialogType)type andLevel:(int)level  {
    if (self = [super initWithNibName:@"ShamelessPromotionViewController" bundle:nil]) {
        _level = level;
        _type = type;
    }
    return self;
}

- (void)configureButton:(UIButton *)button withColor:(UIColor *)color {
    [button addRoundedCorners:button.frame.size.height/2.0f];
    [button setBackgroundColor:color];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
}

- (void)setupText {
    switch (self.type) {
        case ShamelessDialogTypeAbout:
        {
            self.textLabel.text = @"We hope you find Cabalot amazing.\nPlease help share Cabalot with your friends!";
            break;
        }
        case ShamelessDialogTypeSavings:
        {
            float savings = [globalStateInterface savingsTillNow];
            if (savings > 0.0) {
                self.textLabel.text = [NSString stringWithFormat:@"Cabalot has saved $%.2f till now.\nPlease help share Cabalot with your friends!", savings];
            } else {
                self.textLabel.text = @"We hope you find Cabalot amazing.\nPlease help share Cabalot with your friends!";
            }
            break;
        }
        case ShamelessDialogTypeUsage:
        {
            switch (self.level) {
                case 0:
                    self.textLabel.text = @"It seems you like Cabalot.\nPlease help share Cabalot with your friends!";
                    break;
                case 1:
                    self.textLabel.text = @"It seems you love Cabalot.\nPlease help share this love with your friends!";
                    break;
                case 2:
                    self.textLabel.text = @"You find Cabalot amazing!\nPlease help share this with your friends!";
                    break;
                default:
                    self.textLabel.text = @"We hope you find Cabalot amazing.\nPlease help share Cabalot with your friends!";
                    break;
            }

        }
    }
}

- (NSMutableDictionary *)extProperties {
    return [NSMutableDictionary dictionaryWithDictionary:@{@"level" : @(self.level),
                                                           @"type" : @(self.type)}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.85];
    
    [self configureButton:self.fbButton withColor:UIColorFromRGB(0x3B5998)];
    [self configureButton:self.twitterButton withColor:UIColorFromRGB(0x4099FF)];
    [self configureButton:self.textButton withColor:UIColorFromRGB(0x4CD964)];
    [self configureButton:self.emailButton withColor:UIColorFromRGB(0xFF9500)];
    
    self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];
    self.textLabel.textColor = [UIColor whiteColor];
    
    self.closeButton.hitAreaSize = CGSizeMake(50,50);
    [self setupText];
    
    [globalStateInterface.eventLogger trackEventName:@"open-shameless" properties:[self extProperties]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)didPressCloseButton:(id)sender {
    [globalStateInterface.eventLogger trackEventName:@"close-shameless" properties:[self extProperties]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didPressButton:(id)sender {
    if (sender == self.fbButton) {
        [globalStateInterface.eventLogger trackEventName:@"attemptShareFb" properties:[self extProperties]];
        [FbManager shareToFb];
    } else if (sender == self.twitterButton) {
        [globalStateInterface.eventLogger trackEventName:@"attemptShareTwitter" properties:[self extProperties]];
        NSString *tweetText = @"Use @cabalotapp to find cheaper cab rides. Download it at www.cabalotapp.com";
        if (self.type == ShamelessDialogTypeSavings && globalStateInterface.savingsTillNow > 0.0f) {
            tweetText = [NSString stringWithFormat:@"Used @cabalotapp to save $%.2f on cab rides. Download it at www.cabalotapp.com", globalStateInterface.savingsTillNow];
        }
        [FbManager shareToTwitter:tweetText];
    } else if (sender ==  self.textButton) {
        [globalStateInterface.eventLogger trackEventName:@"attemptShareText" properties:[self extProperties]];
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText])
        {
            controller.body = @"I have been using cabalot to get cheaper rides. Try it at www.cabalotapp.com";
            if (self.type == ShamelessDialogTypeSavings && globalStateInterface.savingsTillNow > 0.0f) {
                controller.body = [NSString stringWithFormat:@"I have saved $%.2f on cab rides using cabalot. Try it at www.cabalotapp.com", globalStateInterface.savingsTillNow];
            }
            controller.messageComposeDelegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        } else {
            NSString *message = [NSString stringWithFormat:@"Mail client not set up."];
            CabaggAlertController *alert = [CabaggAlertController alertControllerWithTitle:@"Unknown error" message:message];
            [alert show];
        }
    } else if (sender ==  self.emailButton) {
        [globalStateInterface.eventLogger trackEventName:@"attemptShareMail" properties:[self extProperties]];
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setSubject:@"Get Cabalot"];
            [controller setMessageBody:@"I have been using Cabalot to help me find cheaper cab rides. Give it a shot!\nDownload it at www.cabalotapp.com" isHTML:NO];
            if (controller) {
                [self presentViewController:controller animated:YES completion:nil];
            }
        } else {
            NSString *message = [NSString stringWithFormat:@"Mail client not set up."];
            CabaggAlertController *alert = [CabaggAlertController alertControllerWithTitle:@"Unknown error" message:message];
            [alert show];
        }
    }
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Cancelled");
            break;
        case MessageComposeResultFailed:
            NSLog(@"Unknown Error");
            [[CabaggAlertController alertControllerWithTitle:@"Unkwown error" message:@"Error in sending message"] show];
            break;
        case MessageComposeResultSent:
            NSLog(@"sent");
            [globalStateInterface.eventLogger trackEventName:@"sharedToText" properties:@{@"enabled" : @(YES)}];
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"sent");
            [globalStateInterface.eventLogger trackEventName:@"sharedToEmail" properties:@{@"enabled" : @(YES)}];
            break;
        case MFMailComposeResultFailed:
            [[CabaggAlertController alertControllerWithTitle:@"Unkwown error" message:@"Error in sending email"] show];
            break;
            
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
