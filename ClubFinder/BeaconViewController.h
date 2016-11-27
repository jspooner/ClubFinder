//
//  BeaconViewController.h
//  ClubFinder
//
//  Created by Jonathan Spooner on 4/25/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeaconManager.h"

@interface BeaconViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) BeaconManager *beaconManager;
@property (nonatomic) IBOutlet UITableView *tableView;
-(id)initWithBeacon:(BeaconManager *)manager;
@end
