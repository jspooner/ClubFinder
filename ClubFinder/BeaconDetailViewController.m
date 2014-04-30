//
//  BeaconDetailViewController.m
//  ClubFinder
//
//  Created by Jonathan Spooner on 4/30/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import "BeaconDetailViewController.h"

@interface BeaconDetailViewController ()

@end

@implementation BeaconDetailViewController

-(id)initWithBeacon:(BeaconManager *)manager andTransmitter:(NSString *)identifer
{
    self = [super initWithNibName:@"BeaconDetailViewController" bundle:nil];
    if (self) {
        self.beaconManager = manager;
        self.transmitter = [self transmitterForID:identifer];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.transmitter == nil) {
        [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"I couldn't find that beacon" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil] show];
    }
    self.title = [NSString stringWithFormat:@"Beacon %@", self.transmitter.name];
    self.nameLabel.text = self.transmitter.name;
}

#pragma mark - 
#pragma mark - Helpers

/**
 *
 * TODO Move to BeconManager
 *
 **/
- (Transmitter *)transmitterForID:(NSString *)ID {
    for (Transmitter *transmitter in self.beaconManager.transmitters) {
        if ([transmitter.identifier isEqualToString:ID]) {
            return transmitter;
        }
    }
    for (Transmitter *transmitter in self.beaconManager.mySavedTransmitters) {
        if ([transmitter.identifier isEqualToString:ID]) {
            return transmitter;
        }
    }
    return nil;
}


@end
