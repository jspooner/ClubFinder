//
//  BeaconViewController.m
//  ClubFinder
//
//  Created by Jonathan Spooner on 4/25/14.
//  Copyright (c) 2014 One Bear Nine Ventures. All rights reserved.
//

#import "BeaconViewController.h"
#import "SightingsTableViewCell.h"
#import "Transmitter.h"

@interface BeaconViewController ()

@end

@implementation BeaconViewController

-(id)initWithBeacon:(BeaconManager *)manager
{
    self = [super initWithNibName:@"BeaconViewController" bundle:nil];
    if (self) {
        self.beaconManager = manager;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.beaconManager) {
        NSLog(@"I have a beacon manager");
        // You still need to remove listeners before they are deleted.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(transmitterAdded)
                                                     name:@"transmitterAdded"
                                                   object:nil];
    }
    // Do any additional setup after loading the view from its nib.
}

-(void)transmitterAdded
{
    NSLog(@"-----------------------------------------------  transmitterAdded %lu", (unsigned long)[self.beaconManager.transmitters count]);
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.beaconManager.transmitters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyReusableCell";
    SightingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell != nil) {
        Transmitter *transmitter = [self.beaconManager.transmitters objectAtIndex:indexPath.row];
        // Update the transmitter text
        cell.transmitterNameLabel.text = transmitter.name;
        
        // Update the transmitter avatar (icon image)
        //        NSInteger avatarID = [UserSettingsRepository getAvatarIDForTransmitterID:transmitter.identifier];
        //        NSString *imageFilename = [NSString stringWithFormat:@"avatar_%02d.png", avatarID];
        cell.transmitterIcon.image = [UIImage imageNamed:@"Avatar"];
        
//        if ([self isTransmitterAgedOut:transmitter]) {
//            [self grayOutSightingsCell:cell];
//        } else {
//            [self updateSightingsCell:cell withTransmitter:transmitter];
//        }
    } else {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SightingsTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    return cell;
}


#pragma mark -
#pragma mark - UITableViewDelegate


@end
