//
//  LocationSearchViewController.h
//  cabAgg
//
//  Created by Kanav Arora on 1/14/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SPGooglePlacesAutocompletePlace.h"

@interface LocationSearchViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

- (id)initWithIsPickup:(BOOL)isPickup;
- (void)locationSelectedWith:(NSDictionary *)addressDict;
- (void)locationSelectedWithPlace:(SPGooglePlacesAutocompletePlace *)place;

@end
