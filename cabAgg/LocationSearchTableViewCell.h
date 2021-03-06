//
//  LocationSearchTableViewCell.h
//  cabAgg
//
//  Created by Kanav Arora on 1/14/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LocationSearchViewController;
@class SPGooglePlacesAutocompletePlace;
@interface LocationSearchTableViewCell : UITableViewCell

- (void)clearData;
- (void)setupWithAddress:(NSDictionary *)addressDict
                parentVC:(LocationSearchViewController *)parentVC;
- (void)setupWithPlace:(SPGooglePlacesAutocompletePlace *)place
              parentVC:(LocationSearchViewController *)parentVC;

@end
