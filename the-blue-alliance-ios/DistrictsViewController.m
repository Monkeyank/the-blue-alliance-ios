//
//  DistrictsViewController.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/27/15.
//  Copyright (c) 2015 The Blue Alliance. All rights reserved.
//

#import "DistrictsViewController.h"
#import "TBADistrictsViewController.h"
#import "District.h"
#import "DistrictViewController.h"

static NSString *const DistrictsViewControllerEmbed = @"DistrictsViewControllerEmbed";
static NSString *const DistrictViewControllerSegue  = @"DistrictViewControllerSegue";

@interface DistrictsViewController ()

@property (nonatomic, strong) TBADistrictsViewController *districtsViewController;

@end


@implementation DistrictsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    self.yearSelected = ^void(NSNumber *year) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf.districtsViewController cancelRefresh];
        [strongSelf.districtsViewController hideNoDataView];
        
        strongSelf.currentYear = year;
        strongSelf.districtsViewController.year = year;
        
        [strongSelf updateInterface];
    };

    [self configureYears];
    [self styleInterface];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateInterface];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.navigationItem.title = @"Districts";
}

- (void)updateInterface {
    if ([self.districtsViewController.fetchedResultsController.fetchedObjects count] == 0) {
        self.districtsViewController.refresh();
    }
}

#pragma mark - Data Methods

- (void)configureYears {
    NSNumber *year = [TBAYearSelectViewController currentYear];
    self.years = [TBAYearSelectViewController yearsBetweenStartYear:2009 endYear:year.integerValue];
    
    if (self.currentYear == 0) {
        self.currentYear = year;
        self.districtsViewController.year = year;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:DistrictsViewControllerEmbed]) {
        self.districtsViewController = (TBADistrictsViewController *)segue.destinationViewController;
        self.districtsViewController.persistenceController = self.persistenceController;
        self.districtsViewController.year = self.currentYear;
        
        __weak typeof(self) weakSelf = self;
        self.districtsViewController.districtSelected = ^(District *district) {
            [weakSelf performSegueWithIdentifier:DistrictViewControllerSegue sender:district];
        };
    } else if ([segue.identifier isEqualToString:DistrictViewControllerSegue]) {
        District *district = (District *)sender;
        
        DistrictViewController *districtViewController = (DistrictViewController *)segue.destinationViewController;
        districtViewController.persistenceController = self.persistenceController;
        districtViewController.district = district;
    }
}

@end
