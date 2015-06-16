//
//  AboutViewController.m
//  cabAgg
//
//  Created by Kanav Arora on 6/16/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "AboutViewController.h"

#import "GlobalStateInterface.h"
#import "UIView+Border.h"
#import "ExtraViewController.h"
#import "EventLogger.h"

@interface SettingsViewCell : UICollectionViewCell

@property (nonatomic, readwrite, strong) UILabel *titleLabel;
@property (nonatomic, readwrite, strong) UIImageView *actionView;

@end

typedef enum {
    AboutViewRowAppStore =0,
    AboutViewRowInvite,
    AboutViewRowWebsite,
    AboutViewRowFb,
    AboutViewRowFaq,
} AboutViewRow;

#define kLeftIndent 20

@implementation SettingsViewCell

- (void)configureWithTitle:(NSString *)title {
    [self configureWithTitle:title
                isActionable:NO textColor:UIColorFromRGB(0x333333)];
}

- (void)configureWithTitle:(NSString *)title
              isActionable:(BOOL)isActionable {
    [self configureWithTitle:title isActionable:isActionable textColor:UIColorFromRGB(0x333333)];
}

- (void)configureWithTitle:(NSString *)title
              isActionable:(BOOL)isActionable
                 textColor:(UIColor *)textColor {
    if (!self.titleLabel) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
        self.titleLabel.textColor = textColor;
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.titleLabel];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0f constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeading
                                                        multiplier:1.0f constant:kLeftIndent]];
        
        self.actionView = [[UIImageView alloc] init];
        self.actionView.image = [UIImage imageNamed:@"settings-arrow.png"];
        self.actionView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.actionView];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.actionView
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0f constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.actionView
                                                         attribute:NSLayoutAttributeTrailing
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTrailing
                                                        multiplier:1.0f constant:-15]];
    }
    if (!isActionable) {
        self.actionView.hidden = YES;
    } else {
        self.actionView.hidden = NO;
    }
    self.titleLabel.text = title;
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.backgroundColor = UIColorFromRGB(0xEAEAEA);
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end

@interface AboutViewController ()

@property (nonatomic, readwrite, weak) IBOutlet UICollectionView *collectionView;
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupCollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setupCollectionView {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[SettingsViewCell class] forCellWithReuseIdentifier:@"cell"];
    /*[self.settingsCollectionView registerClass:[SettingsBioCell class] forCellWithReuseIdentifier:@"settingsBio"];
    [self.settingsCollectionView registerClass:[SettingsHeaderView class]
                    forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                           withReuseIdentifier:@"headerCell"];
    [self.settingsCollectionView registerClass:[UICollectionReusableView class]
                    forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                           withReuseIdentifier:@"footerCell"];*/
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    SettingsViewCell *cell = (SettingsViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell addConstainedBottomBorderWithColor:UIColorFromRGB(0xc8c8c8) andWidth:0.5f];
    AboutViewRow viewRow = (AboutViewRow)indexPath.row;
    NSString *title = nil;
    switch (viewRow) {
        case AboutViewRowAppStore:
            title = @"Rate in the App Store";
            break;
        case AboutViewRowFb:
            title = @"Like us on Facebook";
            break;
        case AboutViewRowWebsite:
            title = @"cabalotapp.com";
            break;
        case AboutViewRowFaq:
            title =  @"FAQ";
            break;
        case AboutViewRowInvite:
            title = @"Tell your friends";
            break;
    }
    [cell configureWithTitle:title isActionable:YES];
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AboutViewRow viewRow = (AboutViewRow)indexPath.row;
    switch (viewRow) {
        case AboutViewRowAppStore:
        {
            NSString *appStoreUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", kAppId];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStoreUrl]];
            break;
        }
        case AboutViewRowFb:
        {
            NSString *fbPage = [NSString stringWithFormat:@"fb://profile/692002980944969"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbPage]];
            break;
        }
        case AboutViewRowWebsite:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.cabalotapp.com"]];
            break;
        }
        case AboutViewRowFaq:
        {
            ExtraViewController *extraVC = [[ExtraViewController alloc] initWithNibName:@"ExtraViewController" bundle:nil];
            [self.navigationController pushViewController:extraVC animated:YES];
            break;
        }
        case AboutViewRowInvite:
        {
            NSString *message = @"Download cabalot for iOS and find the cheapest ride";
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/app/cabalot/id%@", kAppId]];
            UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[message, url] applicationActivities:nil];
            [self presentViewController:controller animated:YES completion:nil];
            break;
        }
    }
    [globalStateInterface.eventLogger trackEventName:@"about-page" properties:@{@"index" :@(viewRow)}];
}

#pragma mark- UICollectionViewFlowdelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float width = collectionView.frame.size.width;
    float height = 42.0f;
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}


@end
