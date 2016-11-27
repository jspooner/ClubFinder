//
//  MyBagViewController.h
//  ClubFinder
//
//  Created by Jonathan Spooner on 4/27/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeaconManager.h"

@interface MyBagViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) BeaconManager *beaconManager;
@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet UIImageView *backgroundImage;

-(id)initWithBeacon:(BeaconManager *)manager;

@end
