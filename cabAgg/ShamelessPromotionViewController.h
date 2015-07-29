//
//  ShamelessPromotionViewController.h
//  cabAgg
//
//  Created by Kanav Arora on 7/28/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

typedef enum {
    ShamelessDialogTypeAbout = 0,
    ShamelessDialogTypeUsage,
    ShamelessDialogTypeSavings
} ShamelessDialogType;

@interface ShamelessPromotionViewController : UIViewController<MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

- (id)initWithType:(ShamelessDialogType)type andLevel:(int)level;

@end
