//
//  LocationSearchViewController.m
//  cabAgg
//
//  Created by Kanav Arora on 1/14/15.
//  Copyright (c) 2015 LikwidSkin. All rights reserved.
//

#import "LocationSearchViewController.h"

#import "HTTPClient.h"

#import "GlobalStateInterface.h"
#import "MainViewController.h"
#import "LocationSearchTableViewCell.h"

@interface LocationSearchViewController ()

@property (nonatomic, readwrite, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, readwrite, weak) IBOutlet UITableView *tableView;

@property (nonatomic, readwrite, strong) LocationSearchTableViewCell *prototypeCell;
@property (nonatomic, readwrite, strong) NSArray *data;
@property (nonatomic, readwrite, assign) BOOL isPickup;
@end

@implementation LocationSearchViewController

- (id)initWithIsPickup:(BOOL)isPickup {
    self = [super initWithNibName:@"LocationSearchViewController" bundle:nil];
    if (self) {
        _isPickup = isPickup;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.searchBar.delegate = self;
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
    
    NSString *searchText =  searchBar.text;
    if (searchText.length) {
        [[HTTPClient sharedInstance] getGeoCodeFor:searchText startLocation:globalStateInterface.mainVC.currentMapLocation  success:^(NSArray * results) {
            self.data = results;
            [self.tableView reloadData];
        }];
    }
}

#pragma  mark- Search Bar


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //if (indexPath.row == 0) {
    //   return 0.0f;
    //}
    if (!self.prototypeCell)
    {
        self.prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    }
    [self.prototypeCell setupWithAddress:self.data[indexPath.row] parentVC:self];
    
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
    
    LocationSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setupWithAddress:self.data[indexPath.row] parentVC:self];
    
    return cell;
}

- (void)locationSelectedWith:(NSDictionary *)addressDict {
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
