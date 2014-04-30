//
//  BeaconDetailViewController.h
//  ClubFinder
//
//  Created by Jonathan Spooner on 4/30/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeaconManager.h"
#import "Transmitter.h"

@interface BeaconDetailViewController : UIViewController

@property (strong, nonatomic) BeaconManager *beaconManager;
@property (strong, nonatomic) Transmitter *transmitter;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

-(id)initWithBeacon:(BeaconManager *)manager andTransmitter:(NSString *)identifer;

@end
