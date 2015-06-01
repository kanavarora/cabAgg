//
//  LocationSearchViewController.m
//  cabAgg
//
//  Created by Kanav Arora on 1/14/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "LocationSearchViewController.h"

#import "HTTPClient.h"
#import "UIView+LoadingSpinner.h"

#import "CoreData+MagicalRecord.h"
#import "Search.h"

#import "GlobalStateInterface.h"
#import "MainViewController.h"
#import "LocationSearchTableViewCell.h"
#import "EventLogger.h"

@interface LocationSearchViewController ()

@property (nonatomic, readwrite, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, readwrite, weak) IBOutlet UITableView *tableView;

@property (nonatomic, readwrite, strong) LocationSearchTableViewCell *prototypeCell;
@property (nonatomic, readwrite, strong) NSArray *data;
@property (nonatomic, readwrite, assign) BOOL isPickup;
@property (nonatomic, readwrite, strong) NSMutableArray *savedSearches;
@property (nonatomic, readwrite, assign) BOOL isShowingSavedResults;

@end

@implementation LocationSearchViewController

- (id)initWithIsPickup:(BOOL)isPickup {
    self = [super initWithNibName:@"LocationSearchViewController" bundle:nil];
    if (self) {
        _isPickup = isPickup;
        _isShowingSavedResults = YES;
        NSArray *searchEntities = [Search MR_findAllSortedBy:@"times" ascending:NO];
        //NSArray *searchEntities = @[];
        _savedSearches = [NSMutableArray array];
        for (Search *search in searchEntities) {
            NSMutableDictionary *searchDict = [NSMutableDictionary dictionary];
            searchDict[@"formattedAddress"] = search.address;
            searchDict[@"latitude"] = search.lat;
            searchDict[@"longitude"] = search.lon;
            [_savedSearches addObject:searchDict];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search for address or place...";
    [self setupTableView];
}

- (void)setupTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:@"LocationSearchTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Search Delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    [self.tableView showConstrainedSpinner];
    NSString *searchText =  searchBar.text;
    if (searchText.length) {
        [globalStateInterface.eventLogger trackEventName:@"search-tapped" properties:@{@"searchTerm":searchText}];
        [[HTTPClient sharedInstance] getGeoCodeFor:searchText startLocation:globalStateInterface.mainVC.currentMapLocation  success:^(NSArray * results) {
            self.data = results;
            self.isShowingSavedResults = NO;
            [self.tableView removeSpinner];
            [self.tableView reloadData];
        }];
    }
}

#pragma  mark- Search Bar


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.isShowingSavedResults ? self.savedSearches.count:self.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //if (indexPath.row == 0) {
    //   return 0.0f;
    //}
    NSArray *resultsData = self.isShowingSavedResults ? self.savedSearches : self.data;
    if (!self.prototypeCell)
    {
        self.prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    }
    [self.prototypeCell setupWithAddress:resultsData[indexPath.row] parentVC:self];
    
    [self.prototypeCell setNeedsLayout];
    [self.prototypeCell layoutIfNeeded];
    CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return size.height+1.0f; //1 for separator lines
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //if (indexPath.row == 0) {
    //    return [UITableViewCell new];
    //}
    static NSString *cellIdentifier = @"cell";
    NSArray *resultsData = self.isShowingSavedResults ? self.savedSearches : self.data;
    
    LocationSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setupWithAddress:resultsData[indexPath.row] parentVC:self];
    
    return cell;
}

- (void)locationSelectedWith:(NSDictionary *)addressDict {
    NSArray *results = [Search MR_findByAttribute:@"address" withValue:addressDict[@"formattedAddress"]];
    Search *clickedEntity = nil;
    if (!results.count) {
        clickedEntity = [Search MR_createEntity];
        clickedEntity.address = addressDict[@"formattedAddress"];
        clickedEntity.lon = addressDict[@"longitude"];
        clickedEntity.lat = addressDict[@"latitude"];
        clickedEntity.times = @(0);
    } else {
        clickedEntity = results[0];
    }
    clickedEntity.times = @([clickedEntity.times intValue] + 1);
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
    
    [globalStateInterface.eventLogger trackEventName:@"search-result-tapped" properties:@{@"address": addressDict[@"formattedAddress"]}];
    [self dismissViewControllerAnimated:YES completion:^{
        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake([addressDict[@"latitude"] floatValue], [addressDict[@"longitude"] floatValue]);
        if (self.isPickup) {
            [globalStateInterface.mainVC updatePickupLocation:loc
                                                      address:addressDict[@"formattedAddress"]
                                                   moveRegion:YES];
        } else {
            [globalStateInterface.mainVC updateDestinationLocation:loc
                                                           address:addressDict[@"formattedAddress"]
                                                        moveRegion:YES];
        }
    }];
}

@end
